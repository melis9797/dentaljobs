import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detail page for clinic transfer and equipment listings (contact by phone).
class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.phone,
    this.description,
  });

  final String title;
  final String subtitle;
  final List<String> chips;
  final String phone;
  final String? description;

  Future<void> _call(BuildContext context) async {
    var launched = false;
    try {
      launched = await launchUrl(Uri(scheme: 'tel', path: phone));
    } catch (_) {}
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arama başlatılamadı. Numara: $phone')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final text = description;
    return Scaffold(
      appBar: AppBar(title: const Text('İlan detayı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [for (final c in chips) Chip(label: Text(c))],
          ),
          const SizedBox(height: 16),
          Text(
            (text == null || text.isEmpty) ? 'Açıklama eklenmemiş.' : text,
          ),
          const SizedBox(height: 24),
          SelectableText('Telefon: $phone'),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _call(context),
            icon: const Icon(Icons.phone),
            label: const Text('Ara'),
          ),
        ),
      ),
    );
  }
}
