import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({super.key});

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      print('🔔 Loading notifications for user: ${authProvider.currentUser!.uid}');
      print('🔔 User location: ${authProvider.currentUser!.location.toDocumentId()}');

      await notificationProvider.loadNotifications(
        authProvider.currentUser!.location,
        userId: authProvider.currentUser!.uid,
      );

      print('🔔 Loaded ${notificationProvider.notifications.length} notifications');
      for (var notif in notificationProvider.notifications) {
        print('  - ${notif.type}: ${notif.title} (userId: ${notif.userId})');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton.icon(
              onPressed: () async {
                await notificationProvider.markAllAsRead(authProvider.currentUser!.location);
              },
              icon: Icon(Icons.done_all, size: 18),
              label: Text('Mark all read'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brightBlue,
              ),
            ),
        ],
      ),
      body: notificationProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.brightBlue))
          : notificationProvider.notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ll see updates from your barangay here',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        color: AppColors.brightBlue,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notificationProvider.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationProvider.notifications[index];
            return _buildNotificationCard(notification, authProvider, notificationProvider);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
      notification,
      AuthProvider authProvider,
      NotificationProvider notificationProvider,
      ) {
    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case 'critical':
        typeColor = AppColors.coralRed;
        typeIcon = Icons.warning_amber_rounded;
        break;
      case 'announcement':
        typeColor = AppColors.brightBlue;
        typeIcon = Icons.campaign_rounded;
        break;
      case 'report_update':
        typeColor = Colors.green;
        typeIcon = Icons.check_circle_outline;
        break;
      default:
        typeColor = AppColors.goldenYellow;
        typeIcon = Icons.info_outline;
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: notification.read ? AppColors.white : typeColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.read
                ? Colors.grey.shade200
                : typeColor.withValues(alpha: 0.3),
            width: notification.read ? 1 : 2,
          ),
        ),
      child: InkWell(
        onTap: () async {
          if (!notification.read) {
            await notificationProvider.markAsRead(
              notification.id,
              authProvider.currentUser!.location,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.charcoalBlack.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification.createdAt),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}