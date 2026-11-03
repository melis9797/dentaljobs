import 'package:flutter/material.dart';

import '../blog_service.dart';
import '../legal_texts.dart';
import '../supabase_client.dart';
import '../validators.dart';
import 'legal_screen.dart';

/// First-time setup for writing in the blog: pick a nickname and accept the rules.
class BlogJoinScreen extends StatefulWidget {
  const BlogJoinScreen({super.key});

  @override
  State<BlogJoinScreen> createState() => _BlogJoinScreenState();
}

class _BlogJoinScreenState extends State<BlogJoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  bool _accepted = false;
  bool _saving = false;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      _snack('Devam etmek için kuralları kabul etmelisin.');
      return;
    }
    setState(() => _saving = true);
    try {
      await supabase.rpc(
        'join_blog',
        params: {'p_nickname': normalizeNickname(_nickname.text)},
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _snack(blogErrorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bloga katıl')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Blogda gerçek adın değil, seçeceğin bir takma ad görünür. '
              'Takma adı sonradan değiştiremezsin.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nickname,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Takma ad',
                helperText: '3-20 karakter: a-z, 0-9 ve _',
                border: OutlineInputBorder(),
              ),
              validator: nicknameField,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kısaca kurallar',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '• Hasta bilgisi (ad, T.C. no, telefon, fotoğraf) paylaşma.\n'
                      '• Hakaret, iftira, tehdit ve spam yok.\n'
                      '• Yazından sen sorumlusun.\n'
                      '• Yazıların, zamanı ve IP adresinle birlikte kaydedilir; '
                      'mahkeme veya yetkili makam isterse yasal yoldan '
                      'paylaşılabilir.',
                    ),
                    TextButton(
                      onPressed: () => openLegal(context, communityRules),
                      child: const Text('Tüm kuralları oku'),
                    ),
                  ],
                ),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _accepted,
              onChanged: (v) => setState(() => _accepted = v ?? false),
              title: const Text(
                'Topluluk kurallarını okudum ve kabul ediyorum.',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Devam et'),
            ),
          ],
        ),
      ),
    );
  }
}
