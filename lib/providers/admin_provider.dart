import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AdminProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _users = [];
  List<UserModel> _pendingUsers = [];
  Map<String, int> _statistics = {};
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  List<UserModel> get pendingUsers => _pendingUsers;
  Map<String, int> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  // Load all users
  Future<void> loadAllUsers(LocationData location) async {
    try {
      setLoading(true);
      clearError();
      _users = await _firestoreService.getAllUsers(location);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Load pending users
  Future<void> loadPendingUsers(LocationData location) async {
    try {
      setLoading(true);
      clearError();
      _pendingUsers = await _firestoreService.getPendingUsers(location);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Load statistics
  Future<void> loadStatistics(LocationData location) async {
    try {
      _statistics = await _firestoreService.getUserStatistics(location);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  // Approve user
  Future<bool> approveUser(String uid, LocationData location) async {
    try {
      setLoading(true);
      clearError();
      await _firestoreService.approveUser(uid, location);
      await loadPendingUsers(location);
      await loadStatistics(location);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Reject user
  Future<bool> rejectUser(String uid, LocationData location) async {
    try {
      setLoading(true);
      clearError();
      await _firestoreService.rejectUser(uid, location);
      await loadPendingUsers(location);
      await loadStatistics(location);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Search users
  Future<void> searchUsers(LocationData location, String query) async {
    try {
      setLoading(true);
      clearError();
      if (query.isEmpty) {
        await loadAllUsers(location);
      } else {
        _users = await _firestoreService.searchUsers(location, query);
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Filter by status
  Future<void> filterByStatus(LocationData location, String status) async {
    try {
      setLoading(true);
      clearError();
      _users = await _firestoreService.getUsersByStatus(location, status);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}