import 'package:flutter/material.dart';
import '../../models/parent_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/parent/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'All';

  static const _filters = ['All', 'Unread', 'Spent', 'Chores', 'Limits'];

  List<AppNotification> get _filtered {
    final all = ParentData.notifications;
    switch (_filter) {
      case 'Unread':
        return all.where((n) => !n.isRead).toList();
      case 'Spent':
        return all
            .where((n) => n.type == NotificationType.spent)
            .toList();
      case 'Chores':
        return all
            .where((n) => n.type == NotificationType.choreCompleted)
            .toList();
      case 'Limits':
        return all
            .where((n) => n.type == NotificationType.limitExceeded)
            .toList();
      default:
        return all;
    }
  }

  int get _unreadCount =>
      ParentData.notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    for (final n in ParentData.notifications) {
      n.isRead = true;
    }
    setState(() {});
  }

  void _dismiss(AppNotification notification) {
    ParentData.removeNotification(notification.id);
    setState(() {});
  }

  void _tapNotification(AppNotification notification) {
    ParentData.markNotificationRead(notification.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.parentSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.parentPrimary,
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              UnreadBadge(count: _unreadCount),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Filter chips ─────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) {
                  final isActive = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isActive ? AppTheme.parentGradient : null,
                          color: isActive ? null : const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow:
                              isActive ? AppTheme.parentSoftShadow : [],
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : AppTheme.parentTextMuted,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Notification list ─────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(filter: _filter)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final notif = filtered[i];
                      return NotificationTile(
                        notification: notif,
                        onTap: () => _tapNotification(notif),
                        onDismiss: () => _dismiss(notif),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.parentPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: AppTheme.parentPrimary,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.parentTextDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filter == 'All'
                ? 'You\'re all caught up!'
                : 'No "$filter" notifications right now',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.parentTextMuted,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
