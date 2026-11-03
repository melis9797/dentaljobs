import 'package:flutter/material.dart';

import '../blog_service.dart';
import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';
import 'blog_topic_screen.dart';

/// Moderation queue: open reports grouped by reported post or topic title.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await supabase.rpc('admin_open_reports');
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<void> _openTopic(BuildContext context, String topicId) async {
    final navigator = Navigator.of(context);
    String title = 'Başlık';
    try {
      final row = await supabase
          .from('blog_topics')
          .select('title')
          .eq('id', topicId)
          .maybeSingle();
      title = (row?['title'] as String?) ?? title;
    } catch (_) {}
    navigator.push(
      MaterialPageRoute(
        builder: (_) => BlogTopicScreen(topicId: topicId, title: title),
      ),
    );
  }

  Future<void> _act(
    BuildContext context,
    Map<String, dynamic> report,
    String action,
    VoidCallback reload,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (action == 'ban') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Yazar yasaklansın mı?'),
          content: const Text(
            'İçerik gizlenir ve bu üye bir daha blogda yazamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yasakla'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    try {
      await supabase.rpc('admin_moderate', params: {
        'p_kind': report['target_kind'],
        'p_id': report['target_id'],
        'p_action': action,
      });
      reload();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(blogErrorText(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Şikayetler')),
      body: AsyncList(
        load: _load,
        emptyText: 'Bekleyen şikayet yok.',
        itemBuilder: (context, report, reload) {
          final isEntry = report['target_kind'] == 'entry';
          final hidden = report['content_status'] == 'hidden';
          final reasons = [
            for (final r in (report['reasons'] as List? ?? []))
              reportReasons[r] ?? '$r',
          ];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isEntry ? 'Yazı' : 'Başlık'} · ${report['author_nickname']} · '
                    '${report['report_count']} şikayet'
                    '${hidden ? ' · gizli' : ''}',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(report['content'] as String),
                  const SizedBox(height: 6),
                  Text(
                    'Neden: ${reasons.join(', ')}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _openTopic(
                          context,
                          report['topic_id'] as String,
                        ),
                        child: const Text('Başlığı aç'),
                      ),
                      if (hidden)
                        OutlinedButton(
                          onPressed: () => _act(context, report, 'restore', reload),
                          child: const Text('Geri aç'),
                        )
                      else
                        FilledButton(
                          onPressed: () => _act(context, report, 'hide', reload),
                          child: const Text('Gizle'),
                        ),
                      OutlinedButton(
                        onPressed: () => _act(context, report, 'ban', reload),
                        child: const Text('Gizle + yasakla'),
                      ),
                      TextButton(
                        onPressed: () => _act(context, report, 'dismiss', reload),
                        child: const Text('Şikayeti kapat'),
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
