import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';
import '../supabase_client.dart';
import 'auth_screen.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.job});

  final Map<String, dynamic> job;

  void _snack(BuildContext context, String text) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<String?> _askMessage(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Başvuru'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Kısa bir not ekle (isteğe bağlı)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Future<void> _apply(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }
    final profile = await fetchMyProfile();
    if (!context.mounted) return;
    if (profile?['role'] == 'clinic') {
      _snack(context, 'Klinik hesapları ilanlara başvuramaz.');
      return;
    }
    final message = await _askMessage(context);
    if (message == null) return;
    try {
      await supabase.from('applications').insert({
        'job_id': job['id'],
        'applicant_id': user.id,
        'message': message.isEmpty ? null : message,
      });
      _snack(context, 'Başvurun gönderildi.');
    } on PostgrestException catch (e) {
      _snack(
        context,
        e.code == '23505'
            ? 'Bu ilana zaten başvurdun.'
            : 'Başvuru gönderilemedi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinic = job['clinics'] as Map<String, dynamic>?;
    final district = job['district'] as String?;
    final description = job['description'] as String?;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('İlan detayı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(job['title'] as String, style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${(clinic?['name'] as String?) ?? 'Klinik'} · ${job['city']}'
            '${district == null ? '' : ' / $district'}',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(specialties[job['specialty']] ?? '')),
              Chip(label: Text(employmentTypes[job['employment_type']] ?? '')),
              Chip(
                label: Text(salaryText(
                  job['salary_min'] as int?,
                  job['salary_max'] as int?,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            (description == null || description.isEmpty)
                ? 'Açıklama eklenmemiş.'
                : description,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => _apply(context),
            child: const Text('Başvur'),
          ),
        ),
      ),
    );
  }
}
