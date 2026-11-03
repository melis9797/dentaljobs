import 'package:flutter/material.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';
import '../widgets/filter_dropdown.dart';
import 'job_detail_screen.dart';

class JobsTab extends StatefulWidget {
  const JobsTab({super.key});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab>
    with AutomaticKeepAliveClientMixin {
  String? _city;
  String? _profile;
  String? _experience;
  String? _specialty;

  @override
  bool get wantKeepAlive => true;

  Future<List<Map<String, dynamic>>> _load() async {
    var query =
        supabase.from('jobs').select('*, clinics(name)').eq('status', 'open');
    if (_city != null) query = query.eq('city', _city!);
    if (_profile != null) query = query.eq('job_profile', _profile!);
    if (_profile == 'staff' && _experience != null) {
      query = query.eq('experience_level', _experience!);
    }
    if (_profile == 'specialist' && _specialty != null) {
      query = query.eq('specialty', _specialty!);
    }
    final data = await query.order('created_at', ascending: false).limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FilterDropdown(
                  allLabel: 'Tüm şehirler',
                  value: _city,
                  options: cityOptions,
                  onChanged: (v) => setState(() => _city = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilterDropdown(
                  allLabel: 'Tüm pozisyonlar',
                  value: _profile,
                  options: jobProfiles,
                  onChanged: (v) => setState(() {
                    _profile = v;
                    _experience = null;
                    _specialty = null;
                  }),
                ),
              ),
            ],
          ),
          if (_profile == 'staff')
            FilterDropdown(
              allLabel: 'Tüm deneyim grupları',
              value: _experience,
              options: experienceLevels,
              onChanged: (v) => setState(() => _experience = v),
            ),
          if (_profile == 'specialist')
            FilterDropdown(
              allLabel: 'Tüm branşlar',
              value: _specialty,
              options: specialistBranches,
              onChanged: (v) => setState(() => _specialty = v),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AsyncList(
      reloadKey: '$_city|$_profile|$_experience|$_specialty',
      load: _load,
      header: _filters(),
      emptyText: 'Bu filtrelere uygun ilan yok.',
      itemBuilder: (context, job, _) => _JobTile(job: job),
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
    final employment = employmentTypes[job['employment_type']] ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        isThreeLine: true,
        title: Text(job['title'] as String),
        subtitle: Text(
          '$clinicName · ${job['city']}\n${jobProfileLabel(job)} · $employment',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
        ),
      ),
    );
  }
}
