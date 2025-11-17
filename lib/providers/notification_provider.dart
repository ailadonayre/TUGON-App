import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class NotificationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.read).length;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.read).toList();

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadNotifications(LocationData location, {String? userId}) async {
    try {
      setLoading(true);
      clearError();
      _notifications = await _firestoreService.getNotifications(location, userId: userId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId, LocationData location) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId, location);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> markAllAsRead(LocationData location) async {
    try {
      for (var notification in unreadNotifications) {
        await _firestoreService.markNotificationAsRead(notification.id, location);
      }
      await loadNotifications(location);
    } catch (e) {
      setError(e.toString());
    }
  }
}