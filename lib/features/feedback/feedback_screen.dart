import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/shell_providers.dart';
import '../../app/widgets/widgets.dart';
import 'feedback_client.dart';

/// `/feedback` (CHEESE-51), pushed from About: a short form that the app
/// sends itself through the TK ForgeWorks relay to support. Nothing leaves
/// the phone until Send, and the form shows what is attached.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  static const intro =
      'Found a bug, have an idea, or got lost somewhere? Tell us. It goes '
      'straight to the people who make Cheesy Scribe.';
  static const sentMessage = 'Thanks! Your feedback is on its way.';
  static const failedMessage =
      "That didn't send. Check your connection and try again; your text "
      'is still here.';
  static const footnote =
      'Sent securely to TK ForgeWorks support. Your notes are never included.';

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  static const _gap = SizedBox(height: 18);
  static final _email = RegExp(
    r'^[^\s@<>()",;:\\]+@[^\s@<>()",;:\\]+\.[^\s@<>()",;:\\]+$',
  );

  final _comments = TextEditingController();
  final _replyEmail = TextEditingController();
  FeedbackTopic? _topic;
  int _rating = 0;

  bool _sending = false;
  bool _sent = false;
  bool _failed = false;
  String? _topicError;
  String? _commentsError;
  String? _emailError;

  bool get _dirty =>
      !_sent &&
      (_topic != null ||
          _rating > 0 ||
          _comments.text.trim().isNotEmpty ||
          _replyEmail.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _comments.addListener(
      () => setState(() {
        if (_comments.text.trim().isNotEmpty) _commentsError = null;
      }),
    );
    _replyEmail.addListener(() => setState(() => _emailError = null));
  }

  @override
  void dispose() {
    _comments.dispose();
    _replyEmail.dispose();
    super.dispose();
  }

  // ---- actions ----

  Future<void> _close() async {
    if (!_dirty) {
      context.pop();
      return;
    }
    final discard = await showForgeConfirmSheet(
      context,
      title: 'Discard your feedback?',
      aside: "We'd still like to hear it.",
      confirmLabel: 'Discard',
      cancelLabel: 'Keep writing',
    );
    if (discard && mounted) context.pop();
  }

  Future<void> _send() async {
    final comments = _comments.text.trim();
    final email = _replyEmail.text.trim();
    setState(() {
      _topicError = _topic == null ? 'Pick the closest one.' : null;
      _commentsError = comments.isEmpty
          ? 'Tell us a little about it.'
          : comments.length > FeedbackClient.maxComments
          ? 'Keep it under ${FeedbackClient.maxComments} characters.'
          : null;
      _emailError = email.isNotEmpty && !_email.hasMatch(email)
          ? "That doesn't look like an email address."
          : null;
    });
    if (_topicError != null || _commentsError != null || _emailError != null) {
      return;
    }

    setState(() {
      _sending = true;
      _failed = false;
    });
    try {
      final version = await ref.read(appVersionProvider.future);
      final device = await ref
          .read(feedbackDeviceProvider.future)
          .catchError((_) => _unknownDevice);
      await ref
          .read(feedbackClientProvider)
          .send(
            FeedbackSubmission(
              topic: _topic!,
              rating: _rating,
              comments: comments,
              replyEmail: email.isEmpty ? null : email,
              appVersion: version,
              device: device,
            ),
          );
    } on FeedbackSendException {
      if (mounted) {
        setState(() {
          _sending = false;
          _failed = true;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _sent = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(FeedbackScreen.sentMessage)));
    context.pop();
  }

  // ---- build ----

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Send feedback')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            32,
          ).withNavBarInset(context),
          children: [
            Text(FeedbackScreen.intro, style: context.text.bodyLarge),
            _gap,
            _FormCard(
              label: "What's this about?",
              errorText: _topicError,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in FeedbackTopic.values)
                    FilterChip(
                      label: Text(t.label),
                      selected: _topic == t,
                      onSelected: _sending
                          ? null
                          : (_) => setState(() {
                              _topic = t;
                              _topicError = null;
                            }),
                    ),
                ],
              ),
            ),
            _gap,
            _FormCard(
              label: 'How is Cheesy Scribe working for you?',
              child: StarRating(
                value: _rating,
                size: 30,
                gap: 6,
                showScore: true,
                onChanged: _sending ? null : (v) => setState(() => _rating = v),
              ),
            ),
            _gap,
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: JournalField(
                  label: 'Comments',
                  hint: 'What happened, or what would you like?',
                  controller: _comments,
                  readOnly: _sending,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  errorText: _commentsError,
                ),
              ),
            ),
            _gap,
            JournalField(
              label: 'Email (optional)',
              hint: "Only if you'd like a reply",
              controller: _replyEmail,
              readOnly: _sending,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.none,
              errorText: _emailError,
            ),
            _gap,
            const _AttachedCard(),
            if (_failed) ...[
              _gap,
              ForgeErrorCard(
                message: FeedbackScreen.failedMessage,
                onRetry: _send,
                retryLabel: 'Try again',
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send feedback'),
            ),
            const SizedBox(height: 16),
            Text(
              FeedbackScreen.footnote,
              textAlign: TextAlign.center,
              style: ForgeType.serif(
                size: 13.5,
                italic: true,
                color: context.forge.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _unknownDevice = FeedbackDevice(
  os: 'Android (unknown)',
  model: 'unknown',
);

/// What gets sent along with the form, so nothing is attached unseen.
class _AttachedCard extends ConsumerWidget {
  const _AttachedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).asData?.value;
    final device = ref.watch(feedbackDeviceProvider);
    final d = device.asData?.value ?? (device.hasError ? _unknownDevice : null);
    final style = context.text.bodyMedium?.copyWith(
      color: context.forge.textTertiary,
    );
    return _FormCard(
      label: 'Sent with your feedback',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cheesy Scribe ${version ?? '…'}', style: style),
          Text(d?.os ?? '…', style: style),
          Text(d?.model ?? '…', style: style),
        ],
      ),
    );
  }
}

/// Bordered card with a mono label, one child and an optional error line.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.label, required this.child, this.errorText});

  final String label;
  final Widget child;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ForgeMonoLabel(label),
          const SizedBox(height: 12),
          child,
          if (errorText != null) ...[
            const SizedBox(height: 8),
            // Same treatment as JournalField's error line.
            Text(
              errorText!.toUpperCase(),
              style: context.text.labelMedium!.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
