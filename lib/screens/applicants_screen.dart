import 'package:flutter/material.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';

class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key, required this.job});

  final Map<String, dynamic> job;

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await supabase
        .from('applications')
        .select('*, profiles(full_name, phone, specialty, city)')
        .eq('job_id', job['id'] as String)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> _setStatus(String id, String status) {
    return supabase.from('applications').update({'status': status}).eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(job['title'] as String)),
      body: AsyncList(
        load: _load,
        emptyText: 'Bu ilana henüz başvuru yok.',
        itemBuilder: (context, app, reload) {
          final p = app['profiles'] as Map<String, dynamic>?;
          final status = app['status'] as String;
          final message = app['message'] as String?;
          final phone = p?['phone'] as String?;
          final city = p?['city'] as String?;
          final specialty = specialties[p?['specialty']];
          final details = [
            if (city != null) city,
            if (specialty != null) specialty,
          ].join(' · ');
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (p?['full_name'] as String?) ?? 'İsimsiz aday',
                    style: textTheme.titleMedium,
                  ),
                  if (details.isNotEmpty) Text(details),
                  if (phone != null && phone.isNotEmpty) Text('Telefon: $phone'),
                  if (message != null && message.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(message),
                  ],
                  const SizedBox(height: 8),
                  Text('Durum: ${applicationStatuses[status] ?? status}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: status == 'rejected'
                            ? null
                            : () async {
                                await _setStatus(app['id'] as String, 'rejected');
                                reload();
                              },
                        child: const Text('Reddet'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: status == 'accepted'
                            ? null
                            : () async {
                                await _setStatus(app['id'] as String, 'accepted');
                                reload();
                              },
                        child: const Text('Kabul et'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
