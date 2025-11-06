import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class PostProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<PostModel> _barangayPosts = [];
  List<PostModel> _communityPosts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get barangayPosts => _barangayPosts;
  List<PostModel> get communityPosts => _communityPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PostModel> get pinnedBarangayPosts =>
      _barangayPosts.where((p) => p.pinned).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<PostModel> get regularBarangayPosts =>
      _barangayPosts.where((p) => !p.pinned).toList();

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

  Future<void> loadBarangayPosts(LocationData location) async {
    try {
      setLoading(true);
      clearError();
      _barangayPosts = await _firestoreService.getPosts(location, 'barangay');
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadCommunityPosts(LocationData location) async {
    try {
      setLoading(true);
      clearError();
      _communityPosts = await _firestoreService.getPosts(location, 'community');
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadAllPosts(LocationData location) async {
    await Future.wait([
      loadBarangayPosts(location),
      loadCommunityPosts(location),
    ]);
  }

  Future<bool> createPost({
    required LocationData location,
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    required String type,
    bool pinned = false,
    bool isCritical = false,
    String? imageUrl,
  }) async {
    try {
      setLoading(true);
      clearError();

      final post = PostModel(
        id: '',
        type: type,
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        imageUrl: imageUrl,
        pinned: pinned,
        isCritical: isCritical,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createPost(post, location);
      await loadAllPosts(location);

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> togglePin(String postId, LocationData location, bool pinned) async {
    try {
      await _firestoreService.togglePostPin(postId, location, pinned);
      await loadBarangayPosts(location);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }
}