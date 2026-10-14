import 'dart:convert';

import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:cheesy_scribe/features/feedback/feedback_client.dart';
import 'package:cheesy_scribe/features/feedback/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support.dart';

Finder field(String label) => find.descendant(
  of: find.ancestor(
    of: find.text(label.toUpperCase()),
    matching: find.byType(JournalField),
  ),
  matching: find.byType(TextField),
);

void tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Opens About, then the feedback form from its "Send feedback" row.
Future<void> openForm(WidgetTester tester, {http.Client? relay}) async {
  tallScreen(tester);
  await pumpApp(tester, at: '/about', feedbackHttp: relay);
  await tester.tap(find.byKey(ForgeAboutScreen.feedbackKey));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, 'Send feedback'), findsOneWidget);
}

Future<void> tapSend(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Send feedback'));
  await tester.pumpAndSettle();
}

void main() {
  testApp('About opens the form, which shows what it attaches', (tester) async {
    await openForm(tester);
    expect(find.text(FeedbackScreen.intro), findsOneWidget);
    for (final t in FeedbackTopic.values) {
      expect(find.widgetWithText(FilterChip, t.label), findsOneWidget);
    }
    expect(find.text('SENT WITH YOUR FEEDBACK'), findsOneWidget);
    expect(find.text('Cheesy Scribe 0.1.0'), findsOneWidget);
    expect(find.text(testDevice.os), findsOneWidget);
    expect(find.text(testDevice.model), findsOneWidget);

    // Nothing typed: back leaves without asking.
    await systemBack(tester);
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
  });

  testApp('sends the form to the relay and returns to About', (tester) async {
    final requests = <http.Request>[];
    await openForm(
      tester,
      relay: MockClient((request) async {
        requests.add(request);
        return http.Response('{"ok":true}', 200);
      }),
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Idea'));
    await tester.pump();
    final stars = find.descendant(
      of: find.byType(StarRating),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(stars.at(3));
    await tester.enterText(
      field('Comments'),
      '  A cheese board mode, please.  ',
    );
    await tester.enterText(field('Email (optional)'), 'me@example.com');
    await tapSend(tester);

    expect(requests, hasLength(1));
    final r = requests.single;
    expect(r.method, 'POST');
    expect(r.url, Uri.parse('https://tkforgeworks.com/api/feedback'));
    expect(r.headers['content-type'], startsWith('application/json'));
    expect(jsonDecode(r.body), {
      'app': 'cheesy-scribe',
      'topic': 'idea',
      'rating': 4,
      'comments': 'A cheese board mode, please.',
      'replyEmail': 'me@example.com',
      'appVersion': '0.1.0',
      'osVersion': 'Android 16 (SDK 36)',
      'device': 'Google Pixel 9',
    });
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
    expect(find.text(FeedbackScreen.sentMessage), findsOneWidget);
  });

  testApp('rating and email are optional', (tester) async {
    Map<String, Object?>? sent;
    await openForm(
      tester,
      relay: MockClient((request) async {
        sent = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response('{"ok":true}', 200);
      }),
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Just saying hi'));
    await tester.enterText(field('Comments'), 'Hello!');
    await tapSend(tester);
    expect(sent!['topic'], 'hello');
    expect(sent!['rating'], isNull);
    expect(sent!['replyEmail'], isNull);
  });

  testApp('checks the form before sending anything', (tester) async {
    // The default relay fails the test if it is called.
    await openForm(tester);
    await tapSend(tester);
    expect(find.text('PICK THE CLOSEST ONE.'), findsOneWidget);
    expect(find.text('TELL US A LITTLE ABOUT IT.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Bug'));
    await tester.enterText(field('Comments'), 'Stars vanish.');
    await tester.pump();
    expect(find.text('PICK THE CLOSEST ONE.'), findsNothing);
    expect(find.text('TELL US A LITTLE ABOUT IT.'), findsNothing);

    await tester.enterText(field('Email (optional)'), 'not-an-email');
    await tapSend(tester);
    expect(
      find.text("THAT DOESN'T LOOK LIKE AN EMAIL ADDRESS."),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppBar, 'Send feedback'), findsOneWidget);
  });

  testApp('a failed send keeps the text and can be retried', (tester) async {
    var calls = 0;
    await openForm(
      tester,
      relay: MockClient((request) async {
        calls++;
        if (calls == 1) throw http.ClientException('offline', request.url);
        if (calls == 2) return http.Response('{"error":"send_failed"}', 502);
        return http.Response('{"ok":true}', 200);
      }),
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Bug'));
    await tester.enterText(field('Comments'), 'Search ignores accents.');
    await tapSend(tester);
    expect(find.text(FeedbackScreen.failedMessage), findsOneWidget);
    expect(find.text('Search ignores accents.'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text(FeedbackScreen.failedMessage), findsOneWidget);

    await tapSend(tester);
    expect(calls, 3);
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
  });

  testApp('leaving with typed text asks first', (tester) async {
    await openForm(tester);
    await tester.enterText(field('Comments'), 'Half a thought');
    await tester.pump();
    await systemBack(tester);
    expect(find.text('Discard your feedback?'), findsOneWidget);

    await tester.tap(find.text('Keep writing'));
    await tester.pumpAndSettle();
    expect(find.text('Half a thought'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
  });
}
