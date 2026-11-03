import 'package:flutter/material.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';
import '../widgets/sign_in_prompt.dart';
import 'applicants_screen.dart';
import 'post_equipment_screen.dart';
import 'post_job_screen.dart';
import 'post_transfer_screen.dart';

/// The signed-in user's own listings, plus applications (job seekers) or
/// received applications (clinics).
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
        appBar: AppBar(title: const Text('İlanlarım')),
        body: const SignInPrompt(
          message: 'İlanlarını ve başvurularını görmek için giriş yap.',
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
        return _MyHome(isClinic: snap.data?['role'] == 'clinic');
      },
    );
  }
}

class _MyHome extends StatefulWidget {
  const _MyHome({required this.isClinic});

  final bool isClinic;

  @override
  State<_MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<_MyHome> {
  int _version = 0;

  Future<void> _newListing() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isClinic)
              ListTile(
                leading: const Icon(Icons.work_outline),
                title: const Text('İş ilanı'),
                onTap: () => Navigator.pop(ctx, 'job'),
              ),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Klinik devir ilanı'),
              onTap: () => Navigator.pop(ctx, 'transfer'),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: const Text('İmplant / ekipman satış ilanı'),
              onTap: () => Navigator.pop(ctx, 'equipment'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    final Widget screen = switch (choice) {
      'job' => const PostJobScreen(),
      'transfer' => const PostTransferScreen(),
      _ => const PostEquipmentScreen(),
    };
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (created == true && mounted) setState(() => _version++);
  }

  @override
  Widget build(BuildContext context) {
    final isClinic = widget.isClinic;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('İlanlarım'),
          bottom: TabBar(
            tabs: [
              Tab(text: isClinic ? 'İş ilanlarım' : 'Başvurularım'),
              const Tab(text: 'Devir / Ekipman'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Yeni ilan'),
          onPressed: _newListing,
        ),
        body: TabBarView(
          children: [
            isClinic
                ? _ClinicJobsView(version: _version)
                : _MyApplicationsView(version: _version),
            _MyListingsView(version: _version),
          ],
        ),
      ),
    );
  }
}

class _MyApplicationsView extends StatelessWidget {
  const _MyApplicationsView({required this.version});

  final int version;

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
    return AsyncList(
      reloadKey: version,
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
    );
  }
}

class _ClinicJobsView extends StatelessWidget {
  const _ClinicJobsView({required this.version});

  final int version;

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
    return AsyncList(
      reloadKey: version,
      load: _load,
      emptyText: 'Henüz iş ilanı vermedin. Sağ alttan yeni ilan ekle.',
      itemBuilder: (context, job, reload) {
        final isOpen = job['status'] == 'open';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            isThreeLine: true,
            title: Text(job['title'] as String),
            subtitle: Text(
              '${job['city']} · ${jobProfileLabel(job)}\n'
              '${_applicationCount(job)} başvuru · ${isOpen ? 'Açık' : 'Kapalı'}',
            ),
            trailing: Switch(
              value: isOpen,
              onChanged: (open) async {
                try {
                  await supabase
                      .from('jobs')
                      .update({'status': open ? 'open' : 'closed'}).eq(
                          'id', job['id'] as String);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Güncellenemedi.')),
                    );
                  }
                }
                reload();
              },
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ApplicantsScreen(job: job)),
            ),
          ),
        );
      },
    );
  }
}

class _MyListingsView extends StatelessWidget {
  const _MyListingsView({required this.version});

  final int version;

  Future<List<Map<String, dynamic>>> _load() async {
    final uid = supabase.auth.currentUser!.id;
    final transfers =
        await supabase.from('clinic_transfers').select().eq('owner_id', uid);
    final equipment =
        await supabase.from('equipment_listings').select().eq('owner_id', uid);
    final items = <Map<String, dynamic>>[
      for (final t in transfers) {...t, '_table': 'clinic_transfers'},
      for (final e in equipment) {...e, '_table': 'equipment_listings'},
    ];
    items.sort(
      (a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String),
    );
    return items;
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İlan silinsin mi?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşlem yapılamadı. Tekrar dene.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncList(
      reloadKey: version,
      load: _load,
      emptyText:
          'Henüz devir veya ekipman ilanın yok. Sağ alttan yeni ilan ekle.',
      itemBuilder: (context, item, reload) {
        final table = item['_table'] as String;
        final id = item['id'] as String;
        final isTransfer = table == 'clinic_transfers';
        final isOpen = item['status'] == 'open';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(item['title'] as String),
            subtitle: Text(
              '${isTransfer ? 'Klinik devir' : 'İmplant / Ekipman'} · '
              '${item['city']} · ${isOpen ? 'Yayında' : 'Kapalı'}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isOpen,
                  onChanged: (open) async {
                    await _run(context, () async {
                      await supabase
                          .from(table)
                          .update({'status': open ? 'open' : 'closed'}).eq(
                              'id', id);
                    });
                    reload();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Sil',
                  onPressed: () async {
                    final ok = await _confirmDelete(context);
                    if (ok != true || !context.mounted) return;
                    await _run(context, () async {
                      await supabase.from(table).delete().eq('id', id);
                    });
                    reload();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
