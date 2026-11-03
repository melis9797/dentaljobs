import 'package:flutter/material.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';
import '../widgets/sign_in_prompt.dart';
import 'applicants_screen.dart';
import 'post_job_screen.dart';

/// Third-party view: a job seeker's applications, or a clinic's own listings.
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late final Future<Map<String, dynamic>?> _profile = fetchMyProfile();

  @override
  Widget build(BuildContext context) {
    if (supabase.auth.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Başvurular')),
        body: const SignInPrompt(
          message: 'Başvurularını veya ilanlarını görmek için giriş yap.',
        ),
      );
    }
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profile,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data?['role'] == 'clinic'
            ? const _ClinicJobsView()
            : const _MyApplicationsView();
      },
    );
  }
}

class _MyApplicationsView extends StatelessWidget {
  const _MyApplicationsView();

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await supabase
        .from('applications')
        .select('*, jobs(title, city, clinics(name))')
        .eq('applicant_id', supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Başvurularım')),
      body: AsyncList(
        load: _load,
        emptyText: 'Henüz bir ilana başvurmadın.',
        itemBuilder: (context, app, _) {
          final job = app['jobs'] as Map<String, dynamic>?;
          final clinic = job?['clinics'] as Map<String, dynamic>?;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                (job?['title'] as String?) ?? 'İlan kapandı veya kaldırıldı',
              ),
              subtitle: Text(
                '${(clinic?['name'] as String?) ?? ''} ${job?['city'] ?? ''}'
                    .trim(),
              ),
              trailing: Text(applicationStatuses[app['status']] ?? ''),
            ),
          );
        },
      ),
    );
  }
}

class _ClinicJobsView extends StatefulWidget {
  const _ClinicJobsView();

  @override
  State<_ClinicJobsView> createState() => _ClinicJobsViewState();
}

class _ClinicJobsViewState extends State<_ClinicJobsView> {
  int _version = 0;

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await supabase
        .from('jobs')
        .select('*, clinics!inner(owner_id), applications(count)')
        .eq('clinics.owner_id', supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  int _applicationCount(Map<String, dynamic> job) {
    final apps = job['applications'] as List<dynamic>?;
    if (apps == null || apps.isEmpty) return 0;
    return (apps.first as Map<String, dynamic>)['count'] as int? ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlanlarım')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Yeni ilan'),
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const PostJobScreen()),
          );
          if (created == true && mounted) setState(() => _version++);
        },
      ),
      body: AsyncList(
        reloadKey: _version,
        load: _load,
        emptyText: 'Henüz ilan vermedin. Sağ alttan yeni ilan ekle.',
        itemBuilder: (context, job, reload) {
          final isOpen = job['status'] == 'open';
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(job['title'] as String),
              subtitle: Text(
                '${job['city']} · ${_applicationCount(job)} başvuru · '
                '${isOpen ? 'Açık' : 'Kapalı'}',
              ),
              trailing: Switch(
                value: isOpen,
                onChanged: (open) async {
                  await supabase
                      .from('jobs')
                      .update({'status': open ? 'open' : 'closed'}).eq(
                          'id', job['id'] as String);
                  reload();
                },
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ApplicantsScreen(job: job),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
