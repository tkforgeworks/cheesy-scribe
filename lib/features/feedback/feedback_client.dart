import 'dart:async';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// What a piece of feedback is about. [id] is the relay's `topic` value.
enum FeedbackTopic {
  bug('bug', 'Bug'),
  idea('idea', 'Idea'),
  confusing('confusing', 'Something confusing'),
  hello('hello', 'Just saying hi');

  const FeedbackTopic(this.id, this.label);

  final String id;
  final String label;
}

/// The phone the feedback comes from, shown on the form and sent with it.
class FeedbackDevice {
  const FeedbackDevice({required this.os, required this.model});

  /// For example "Android 16 (SDK 36)".
  final String os;

  /// Manufacturer and model, for example "Google Pixel 9".
  final String model;
}

/// One form's worth of feedback, as the website relay expects it
/// (TKForgeWorks_website `functions/api/feedback.ts`, TKFW-82).
class FeedbackSubmission {
  const FeedbackSubmission({
    required this.topic,
    required this.rating,
    required this.comments,
    required this.replyEmail,
    required this.appVersion,
    required this.device,
  });

  final FeedbackTopic topic;

  /// 1-5, or 0 when the user didn't pick one.
  final int rating;
  final String comments;

  /// Null when the user doesn't want a reply.
  final String? replyEmail;
  final String appVersion;
  final FeedbackDevice device;

  Map<String, Object?> toJson() => {
    'app': FeedbackClient.appId,
    'topic': topic.id,
    'rating': rating == 0 ? null : rating,
    'comments': comments,
    'replyEmail': replyEmail,
    'appVersion': appVersion,
    'osVersion': device.os,
    'device': device.model,
  };
}

/// Sending failed: no connection, a timeout, or the relay said no.
class FeedbackSendException implements Exception {
  const FeedbackSendException([this.statusCode]);

  /// The relay's status code, null when it was never reached.
  final int? statusCode;

  @override
  String toString() => 'FeedbackSendException($statusCode)';
}

/// Posts feedback to the TK ForgeWorks relay, which emails it to
/// support@tkforgeworks.com. The app holds no mail credentials.
class FeedbackClient {
  FeedbackClient(this._http);

  final http.Client _http;

  static final endpoint = Uri.https('tkforgeworks.com', '/api/feedback');

  /// This app's id in the relay's allow-list.
  static const appId = 'cheesy-scribe';

  /// Must match the relay's limit.
  static const maxComments = 4000;

  static const timeout = Duration(seconds: 20);

  /// Completes when the relay has accepted [submission]; throws
  /// [FeedbackSendException] otherwise.
  Future<void> send(FeedbackSubmission submission) async {
    final http.Response res;
    try {
      res = await _http
          .post(
            endpoint,
            headers: const {'content-type': 'application/json'},
            body: jsonEncode(submission.toJson()),
          )
          .timeout(timeout);
    } on Exception {
      throw const FeedbackSendException();
    }
    if (res.statusCode != 200) throw FeedbackSendException(res.statusCode);
  }
}

/// Tests replace it with a `MockClient` (see `pumpApp`).
final feedbackHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final feedbackClientProvider = Provider<FeedbackClient>(
  (ref) => FeedbackClient(ref.watch(feedbackHttpClientProvider)),
);

/// Read once from the platform. Tests override it.
final feedbackDeviceProvider = FutureProvider<FeedbackDevice>((ref) async {
  final info = await DeviceInfoPlugin().androidInfo;
  final maker = info.manufacturer;
  // Some makers already start the model with their name ("OnePlus 9").
  final model = info.model.toLowerCase().startsWith(maker.toLowerCase())
      ? info.model
      : '$maker ${info.model}';
  return FeedbackDevice(
    os: 'Android ${info.version.release} (SDK ${info.version.sdkInt})',
    model: model,
  );
});
