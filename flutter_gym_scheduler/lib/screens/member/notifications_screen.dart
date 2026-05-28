import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = true;
  int unread = 0;
  List<AppNotification> items = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      setState(() => loading = true);
      final res = await ApiClient.instance.dio.get('/notifications');
      final list = (res.data['notifications'] as List?) ?? [];
      items = list.map((e) => AppNotification.fromJson((e as Map).cast<String, dynamic>())).toList();
      unread = (res.data['unread_count'] as num?)?.toInt() ?? 0;
      setState(() {});
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> markRead([int? id]) async {
    await ApiClient.instance.dio.post('/notifications/read', data: {'notification_id': id});
    await fetch();
  }

  IconData _icon(String t) {
    switch (t) {
      case 'booking':
        return Icons.event_available_outlined;
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thong bao'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => markRead(),
              child: const Text('Doc het'),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetch,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (items.isEmpty)
                    const EmptyState(icon: Icons.notifications_off_outlined, title: 'Chua co thong bao')
                  else
                    ...items.map(
                      (n) => Card(
                        child: ListTile(
                          onTap: n.isRead ? null : () => markRead(n.id),
                          leading: Icon(_icon(n.type), color: n.isRead ? Colors.blueGrey : Colors.blue),
                          title: Text(n.title ?? 'Thong bao he thong'),
                          subtitle: Text('${n.message}\n${n.createdAt.toLocal()}'),
                          isThreeLine: true,
                          trailing: n.isRead ? null : const Icon(Icons.circle, size: 10, color: Colors.blue),
                        ),
                      ),
                    )
                ],
              ),
            ),
    );
  }
}
