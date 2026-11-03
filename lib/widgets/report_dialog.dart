import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../blog_service.dart';
import '../constants.dart';
import '../screens/auth_screen.dart';
import '../supabase_client.dart';
import '../validators.dart';
import 'form_widgets.dart';

/// Asks for a reason and files a report for a blog post ([entryId]) or a
/// topic title ([topicId]).
Future<void> reportContent(
  BuildContext context, {
  String? entryId,
  String? topicId,
}) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (supabase.auth.currentUser == null) {
    await navigator.push(MaterialPageRoute(builder: (_) => const AuthScreen()));
    if (supabase.auth.currentUser == null) return;
  }
  if (!context.mounted) return;
  final result = await showDialog<({String reason, String? details})>(
    context: context,
    builder: (_) => const _ReportDialog(),
  );
  if (result == null) return;
  try {
    await supabase.from('blog_reports').insert({
      if (entryId != null) 'entry_id': entryId,
      if (topicId != null) 'topic_id': topicId,
      'reason': result.reason,
      'details': result.details,
    });
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Şikayetin alındı. En kısa sürede inceleyeceğiz.'),
      ),
    );
  } on PostgrestException catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          e.code == '23505' ? 'Bunu zaten şikayet ettin.' : blogErrorText(e),
        ),
      ),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Şikayet gönderilemedi. Tekrar dene.')),
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _details = TextEditingController();
  String _reason = reportReasons.keys.first;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Şikayet et'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LabeledDropdown(
              label: 'Neden?',
              value: _reason,
              options: reportReasons,
              onChanged: (v) => setState(() => _reason = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _details,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Açıklama (isteğe bağlı)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            (reason: _reason, details: nullIfEmpty(_details.text)),
          ),
          child: const Text('Şikayet et'),
        ),
      ],
    );
  }
}
