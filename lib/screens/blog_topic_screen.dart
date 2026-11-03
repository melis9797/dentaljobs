import 'package:flutter/material.dart';

import '../blog_service.dart';
import '../constants.dart';
import '../supabase_client.dart';
import '../validators.dart';
import '../widgets/async_list.dart';
import '../widgets/report_dialog.dart';

/// All posts under one topic, with a box to add a new post at the bottom.
class BlogTopicScreen extends StatefulWidget {
  const BlogTopicScreen({super.key, required this.topicId, required this.title});

  final String topicId;
  final String title;

  @override
  State<BlogTopicScreen> createState() => _BlogTopicScreenState();
}

class _BlogTopicScreenState extends State<BlogTopicScreen> {
  final _body = TextEditingController();
  int _version = 0;
  bool _sending = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    fetchIsAdmin().then((value) {
      if (mounted) setState(() => _isAdmin = value);
    });
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await supabase
        .from('blog_entries')
        .select(entryColumns())
        .eq('topic_id', widget.topicId)
        .order('created_at', ascending: true)
        .limit(300);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> _send() async {
    final problem = blogBodyField(_body.text);
    if (problem != null) {
      _snack(problem);
      return;
    }
    final canWrite = await ensureBlogMember(context);
    if (!canWrite || !mounted) return;
    setState(() => _sending = true);
    try {
      await supabase.from('blog_entries').insert({
        'topic_id': widget.topicId,
        'body': _body.text.trim(),
      });
      _body.clear();
      if (mounted) setState(() => _version++);
    } catch (e) {
      _snack(blogErrorText(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _delete(String entryId, VoidCallback reload) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yazı silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await supabase.from('blog_entries').delete().eq('id', entryId);
      reload();
    } catch (_) {
      _snack('Yazı silinemedi. Tekrar dene.');
    }
  }

  Future<void> _moderate(
    String entryId,
    String action,
    VoidCallback reload,
  ) async {
    try {
      await supabase.rpc('admin_moderate', params: {
        'p_kind': 'entry',
        'p_id': entryId,
        'p_action': action,
      });
      reload();
    } catch (e) {
      _snack(blogErrorText(e));
    }
  }

  Widget _entryTile(
    BuildContext context,
    Map<String, dynamic> entry,
    VoidCallback reload,
  ) {
    final theme = Theme.of(context);
    final id = entry['id'] as String;
    final hidden = entry['status'] == 'hidden';
    final mine = entry['author_id'] != null &&
        entry['author_id'] == supabase.auth.currentUser?.id;
    final reason = entry['hidden_reason'] as String?;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: hidden ? theme.colorScheme.surfaceContainerHighest : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hidden)
              Padding(
                padding: const EdgeInsets.only(bottom: 6, right: 8),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_off, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Gizlendi${reason == null ? '' : ': $reason'}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SelectableText(entry['body'] as String),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${entry['author_nickname']} · ${dateTimeText(entry['created_at'] as String?)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                if (mine)
                  IconButton(
                    tooltip: 'Sil',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(id, reload),
                  )
                else
                  IconButton(
                    tooltip: 'Şikayet et',
                    icon: const Icon(Icons.flag_outlined),
                    onPressed: () => reportContent(context, entryId: id),
                  ),
                if (_isAdmin)
                  PopupMenuButton<String>(
                    tooltip: 'Yönetici',
                    onSelected: (action) => _moderate(id, action, reload),
                    itemBuilder: (_) => [
                      if (hidden)
                        const PopupMenuItem(
                          value: 'restore',
                          child: Text('Geri aç'),
                        )
                      else
                        const PopupMenuItem(value: 'hide', child: Text('Gizle')),
                      const PopupMenuItem(
                        value: 'ban',
                        child: Text('Gizle ve yazarı yasakla'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Başlığı şikayet et',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => reportContent(context, topicId: widget.topicId),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AsyncList(
              reloadKey: _version,
              load: _load,
              emptyText: 'Bu başlıkta henüz yazı yok.',
              itemBuilder: _entryTile,
            ),
          ),
          Material(
            elevation: 4,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _body,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 2000,
                        decoration: const InputDecoration(
                          hintText: 'Yazını ekle (hasta bilgisi yazma)',
                          counterText: '',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: 'Gönder',
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
