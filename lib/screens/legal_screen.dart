import 'package:flutter/material.dart';

import '../legal_texts.dart';

/// Read-only page that shows one of the legal documents.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(doc.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in doc.sections) ...[
            Text(section.heading, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            SelectableText(section.body),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

void openLegal(BuildContext context, LegalDoc doc) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => LegalScreen(doc: doc)),
  );
}

/// Links to all legal pages, used on the profile and sign-in screens.
class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () => openLegal(context, termsOfUse),
          child: const Text('Kullanım koşulları'),
        ),
        TextButton(
          onPressed: () => openLegal(context, privacyNotice),
          child: const Text('Aydınlatma metni'),
        ),
        TextButton(
          onPressed: () => openLegal(context, communityRules),
          child: const Text('Topluluk kuralları'),
        ),
        TextButton(
          onPressed: () => openLegal(context, contactAndReports),
          child: const Text('İletişim / bildirim'),
        ),
      ],
    );
  }
}
