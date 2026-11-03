import 'package:flutter/material.dart';

/// Pull-to-refresh list that loads rows once and rebuilds when [reloadKey] changes.
class AsyncList extends StatefulWidget {
  const AsyncList({
    super.key,
    required this.load,
    required this.itemBuilder,
    required this.emptyText,
    this.header,
    this.reloadKey,
  });

  final Future<List<Map<String, dynamic>>> Function() load;
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> item,
    VoidCallback reload,
  ) itemBuilder;
  final String emptyText;
  final Widget? header;
  final Object? reloadKey;

  @override
  State<AsyncList> createState() => _AsyncListState();
}

class _AsyncListState extends State<AsyncList> {
  late Future<List<Map<String, dynamic>>> _future = widget.load();

  void _reload() {
    if (mounted) setState(() => _future = widget.load());
  }

  @override
  void didUpdateWidget(AsyncList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadKey != widget.reloadKey) {
      _future = widget.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _reload();
        try {
          await _future;
        } catch (_) {}
      },
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          final children = <Widget>[];
          if (widget.header != null) children.add(widget.header!);
          if (snap.connectionState != ConnectionState.done) {
            children.add(const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ));
          } else if (snap.hasError) {
            children.add(const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Yüklenemedi. Listeyi aşağı çekerek tekrar dene.'),
            ));
          } else if (snap.data!.isEmpty) {
            children.add(Padding(
              padding: const EdgeInsets.all(24),
              child: Text(widget.emptyText),
            ));
          } else {
            for (final item in snap.data!) {
              children.add(widget.itemBuilder(context, item, _reload));
            }
          }
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: children,
          );
        },
      ),
    );
  }
}
