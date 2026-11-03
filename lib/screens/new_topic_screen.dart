import 'package:flutter/material.dart';

import '../blog_service.dart';
import '../supabase_client.dart';
import '../validators.dart';

/// Opens a new topic together with its first post. Pops with the new topic's
/// id and title so the caller can open it.
class NewTopicScreen extends StatefulWidget {
  const NewTopicScreen({super.key});

  @override
  State<NewTopicScreen> createState() => _NewTopicScreenState();
}

class _NewTopicScreenState extends State<NewTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final id = await supabase.rpc(
        'create_topic',
        params: {'p_title': _title.text.trim(), 'p_body': _body.text.trim()},
      );
      navigator.pop((id: id as String, title: _title.text.trim()));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(blogErrorText(e))));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni başlık')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                helperText: 'Konuyu kısaca anlat',
                border: OutlineInputBorder(),
              ),
              validator: blogTitleField,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _body,
              maxLines: 8,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'İlk yazın',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: blogBodyField,
            ),
            const Text(
              'Hasta bilgisi, hakaret ve reklam yazma. Yazın takma adınla '
              'yayınlanır.',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Başlığı aç'),
            ),
          ],
        ),
      ),
    );
  }
}
