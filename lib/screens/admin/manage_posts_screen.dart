import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import 'create_barangay_post_screen.dart';

class ManagePostsScreen extends StatefulWidget {
  const ManagePostsScreen({super.key});

  @override
  State<ManagePostsScreen> createState() => _ManagePostsScreenState();
}

class _ManagePostsScreenState extends State<ManagePostsScreen> {
  String _selectedFilter = 'all'; // 'all', 'admin', 'user', 'pinned', 'critical'

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final barangayId = authProvider.currentUser?.location.toDocumentId() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Posts & Announcements',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brightBlue),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateBarangayPostScreen(),
            ),
          );
        },
        backgroundColor: AppColors.brightBlue,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text(
          'New Post',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Posts', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Admin Posts', 'admin'),
                  const SizedBox(width: 8),
                  _buildFilterChip('User Posts', 'user'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pinned', 'pinned'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Critical', 'critical'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Posts list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPostsStream(barangayId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.dmSans(color: AppColors.coralRed),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brightBlue,
                    ),
                  );
                }

                var posts = (snapshot.data?.docs ?? []).map((doc) {
                  return PostModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                // Filter client-side based on selected filter
                if (_selectedFilter == 'admin') {
                  posts = posts.where((p) => p.type == 'barangay').toList();
                } else if (_selectedFilter == 'user') {
                  posts = posts.where((p) => p.type == 'community').toList();
                } else if (_selectedFilter == 'pinned') {
                  posts = posts.where((p) => p.pinned).toList();
                } else if (_selectedFilter == 'critical') {
                  posts = posts.where((p) => p.isCritical).toList();
                }

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts found',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return _buildPostCard(posts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getPostsStream(String barangayId) {
    // Use simple query to avoid composite index requirement
    return FirebaseFirestore.instance
        .collection('barangays')
        .doc(barangayId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.white,
      selectedColor: AppColors.brightBlue.withValues(alpha: 0.2),
      checkmarkColor: AppColors.brightBlue,
      labelStyle: GoogleFonts.dmSans(
        color: isSelected ? AppColors.brightBlue : AppColors.charcoalBlack,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.brightBlue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: post.isCritical
              ? AppColors.coralRed
              : post.pinned
                  ? AppColors.goldenYellow
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (post.isCritical) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.coralRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CRITICAL',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (post.pinned) ...[
                            Icon(
                              Icons.push_pin,
                              size: 16,
                              color: AppColors.goldenYellow,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              post.title,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoalBlack,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${post.authorName}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => _handlePostAction(value, post),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(
                            post.pinned ? Icons.push_pin_outlined : Icons.push_pin,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(post.pinned ? 'Unpin' : 'Pin'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'critical',
                      child: Row(
                        children: [
                          Icon(
                            post.isCritical
                                ? Icons.warning_amber_outlined
                                : Icons.warning_amber,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(post.isCritical
                              ? 'Remove Critical'
                              : 'Mark Critical'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.coralRed),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: AppColors.coralRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.charcoalBlack.withValues(alpha: 0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Image if available
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.network(
                post.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _handlePostAction(String action, PostModel post) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final barangayId = authProvider.currentUser?.location.toDocumentId() ?? '';

    try {
      final docRef = FirebaseFirestore.instance
          .collection('barangays')
          .doc(barangayId)
          .collection('posts')
          .doc(post.id);

      switch (action) {
        case 'pin':
          await docRef.update({
            'pinned': !post.pinned,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(post.pinned ? 'Post unpinned' : 'Post pinned'),
                backgroundColor: AppColors.brightBlue,
              ),
            );
          }
          break;

        case 'critical':
          await docRef.update({
            'isCritical': !post.isCritical,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  post.isCritical
                      ? 'Removed critical status'
                      : 'Marked as critical',
                ),
                backgroundColor: AppColors.brightBlue,
              ),
            );
          }
          break;

        case 'delete':
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Delete Post',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete this post? This action cannot be undone.',
                style: GoogleFonts.dmSans(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.dmSans(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.dmSans(color: AppColors.coralRed),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await docRef.delete();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post deleted'),
                  backgroundColor: AppColors.coralRed,
                ),
              );
            }
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
