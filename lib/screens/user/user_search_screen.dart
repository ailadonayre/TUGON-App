import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import 'user_profile_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({required this.post, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null)
              Image.network(post.imageUrl!, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(post.content),
          ],
        ),
      ),
    );
  }
}

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

enum FilterType { all, posts, media, people }
enum PostSort { newest, oldest }
enum PostFlags { pinned, critical }

class _UserSearchScreenState extends State<UserSearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allResults = [];
  List<dynamic> _filteredResults = [];
  FilterType _selectedFilter = FilterType.all;
  PostSort _postSort = PostSort.newest;
  Map<PostFlags, bool> _postFlags = {
    PostFlags.pinned: false,
    PostFlags.critical: false,
  };
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _loading = true);
    try {
      final users = await _firestoreService.getAllUsersAcrossBarangays();
      final posts = await _firestoreService.getAllPostsAcrossBarangays();
      setState(() {
        _allResults = [...users, ...posts];
        _filteredResults = [];
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterResults() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredResults = [];
        return;
      }

      _filteredResults = _allResults.where((item) {
        if (item is UserModel) {
          final name = item.fullName.toLowerCase();
          final email = item.email.toLowerCase();
          if (!name.contains(query) && !email.contains(query)) return false;
          if (_selectedFilter == FilterType.posts || _selectedFilter == FilterType.media) return false;
        } else if (item is PostModel) {
          final title = item.title.toLowerCase();
          final content = item.content.toLowerCase();
          if (!title.contains(query) && !content.contains(query)) return false;
          if (_selectedFilter == FilterType.people) return false;
          if (_selectedFilter == FilterType.media && (item.imageUrl == null || item.imageUrl!.isEmpty)) return false;

          if (_postFlags[PostFlags.pinned]! && !item.pinned) return false;
          if (_postFlags[PostFlags.critical]! && !item.isCritical) return false;
        }
        return true;
      }).toList();

      _filteredResults.sort((a, b) {
        if (a is PostModel && b is PostModel) {
          return _postSort == PostSort.newest
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt);
        }
        return 0;
      });
    });
  }

  void _onFilterChanged(FilterType filter) {
    setState(() => _selectedFilter = filter);
    _filterResults();
  }

  void _onSortChanged(PostSort? sort) {
    if (sort == null) return;
    setState(() => _postSort = sort);
    _filterResults();
  }

  void _onFlagChanged(PostFlags flag, bool value) {
    setState(() => _postFlags[flag] = value);
    _filterResults();
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users or posts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filterResults(),
            ),
          ),

          // Main filter: All / Posts / Media / People (RED)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: FilterType.values.map((filter) {
                final selected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter.name[0].toUpperCase() + filter.name.substring(1)),
                  selected: selected,
                  backgroundColor: Colors.red.withOpacity(0.3),
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => _onFilterChanged(filter),
                );
              }).toList(),
            ),
          ),

          // Divider
          const Divider(height: 1, color: Colors.grey),

          // Secondary filters (always visible, card-like with shadow)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                child: Row(
                  children: [
                    ChoiceChip(
                      avatar: const Icon(Icons.arrow_downward, size: 16),
                      label: const Text('Newest', style: TextStyle(fontSize: 10)),
                      selected: _postSort == PostSort.newest,
                      onSelected: (_) => _onSortChanged(PostSort.newest),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(color: _postSort == PostSort.newest ? Colors.white : Colors.blue),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      avatar: const Icon(Icons.arrow_upward, size: 16),
                      label: const Text('Oldest', style: TextStyle(fontSize: 10)),
                      selected: _postSort == PostSort.oldest,
                      onSelected: (_) => _onSortChanged(PostSort.oldest),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(color: _postSort == PostSort.oldest ? Colors.white : Colors.blue),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      avatar: const Icon(Icons.push_pin, size: 16),
                      label: const Text('Pinned', style: TextStyle(fontSize: 10)),
                      selected: _postFlags[PostFlags.pinned]!,
                      onSelected: (val) => _onFlagChanged(PostFlags.pinned, val),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(color: _postFlags[PostFlags.pinned]! ? Colors.white : Colors.blue),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      avatar: const Icon(Icons.warning, size: 16),
                      label: const Text('Critical', style: TextStyle(fontSize: 10)),
                      selected: _postFlags[PostFlags.critical]!,
                      onSelected: (val) => _onFlagChanged(PostFlags.critical, val),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(color: _postFlags[PostFlags.critical]! ? Colors.white : Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredResults.isEmpty
                ? const Center(child: Text('Start typing to search'))
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final item = _filteredResults[index];

                if (item is UserModel) {
                  return Card(
                    color: Colors.grey[100],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text(
                          item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(item.fullName),
                      subtitle: Text(item.email),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserProfileScreen(user: item)),
                        );
                      },
                    ),
                  );
                } else if (item is PostModel) {
                  return Card(
                    color: Colors.grey[50],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: item.imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(item.imageUrl!, width: 60, height: 60, fit: BoxFit.cover),
                      )
                          : const Icon(Icons.article, size: 40),
                      title: Row(
                        children: [
                          Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                          if (item.pinned)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('PINNED', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                          if (item.isCritical)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('CRITICAL', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'By ${item.authorName} • ${_timeAgo(item.createdAt)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PostDetailScreen(post: item)),
                        );
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


