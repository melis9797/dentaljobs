import 'package:flutter/material.dart';

import '../blog_service.dart';
import '../constants.dart';
import '../legal_texts.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';
import 'admin_screen.dart';
import 'blog_topic_screen.dart';
import 'legal_screen.dart';
import 'new_topic_screen.dart';

/// Sözlük-style community tab: topics, each with posts by nickname.
class BlogTab extends StatefulWidget {
  const BlogTab({super.key});

  @override
  State<BlogTab> createState() => _BlogTabState();
}

class _BlogTabState extends State<BlogTab> {
  int _version = 0;
  bool _isAdmin = false;
  String? _adminForUser;

  Future<void> _checkAdmin() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == _adminForUser) return;
    _adminForUser = userId;
    final value = await fetchIsAdmin();
    if (mounted) setState(() => _isAdmin = value);
  }

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await supabase
        .from('blog_topics')
        .select('$topicColumns,blog_entries(count)')
        .order('last_entry_at', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  int _entryCount(Map<String, dynamic> topic) {
    final counts = topic['blog_entries'];
    if (counts is List && counts.isNotEmpty && counts.first is Map) {
      return (counts.first['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> _openTopic(String id, String title) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlogTopicScreen(topicId: id, title: title),
      ),
    );
    if (mounted) setState(() => _version++);
  }

  Future<void> _newTopic() async {
    final canWrite = await ensureBlogMember(context);
    if (!canWrite || !mounted) return;
    final created = await Navigator.of(context).push<({String id, String title})>(
      MaterialPageRoute(builder: (_) => const NewTopicScreen()),
    );
    if (created == null || !mounted) return;
    await _openTopic(created.id, created.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        actions: [
          if (_isAdmin)
            IconButton(
              tooltip: 'Şikayetler',
              icon: const Icon(Icons.shield_outlined),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
                if (mounted) setState(() => _version++);
              },
            ),
          IconButton(
            tooltip: 'Topluluk kuralları',
            icon: const Icon(Icons.info_outline),
            onPressed: () => openLegal(context, communityRules),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newTopic,
        icon: const Icon(Icons.edit),
        label: const Text('Yeni başlık'),
      ),
      body: AsyncList(
        reloadKey: _version,
        load: _load,
        emptyText: 'Henüz başlık yok. İlk başlığı sen aç.',
        header: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Hasta bilgisi, hakaret ve reklam yasak'),
              subtitle: const Text('Kuralları okumak için dokun'),
              onTap: () => openLegal(context, communityRules),
            ),
          ),
        ),
        itemBuilder: (context, topic, _) {
          final count = _entryCount(topic);
          final hidden = topic['status'] == 'hidden';
          final title = topic['title'] as String;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(title),
              subtitle: Text(
                '${topic['author_nickname']} · $count yazı · '
                '${dateTimeText(topic['last_entry_at'] as String?)}'
                '${hidden ? ' · gizlendi' : ''}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openTopic(topic['id'] as String, title),
            ),
          );
        },
      ),
    );
  }
}
