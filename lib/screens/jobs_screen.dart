import 'package:flutter/material.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String? _city;
  String? _specialty;

  Future<List<Map<String, dynamic>>> _load() async {
    var query =
        supabase.from('jobs').select('*, clinics(name)').eq('status', 'open');
    if (_city != null) query = query.eq('city', _city!);
    if (_specialty != null) query = query.eq('specialty', _specialty!);
    final data = await query.order('created_at', ascending: false).limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: _city,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tüm şehirler'),
                ),
                for (final c in cities)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _city = v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: _specialty,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tüm branşlar'),
                ),
                for (final e in specialties.entries)
                  DropdownMenuItem<String?>(
                    value: e.key,
                    child: Text(e.value, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _specialty = v),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlanlar')),
      body: AsyncList(
        reloadKey: '$_city|$_specialty',
        load: _load,
        header: _filters(),
        emptyText: 'Bu filtrelere uygun ilan yok.',
        itemBuilder: (context, job, _) => _JobTile(job: job),
      ),
    );
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    final clinic = job['clinics'] as Map<String, dynamic>?;
    final clinicName = (clinic?['name'] as String?) ?? 'Klinik';
    final specialty =
        specialties[job['specialty']] ?? (job['specialty'] as String? ?? '');
    final employment = employmentTypes[job['employment_type']] ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        isThreeLine: true,
        title: Text(job['title'] as String),
        subtitle: Text('$clinicName · ${job['city']}\n$specialty · $employment'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
        ),
      ),
    );
  }
}
