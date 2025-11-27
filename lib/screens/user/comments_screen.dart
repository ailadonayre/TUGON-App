import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/comment_service.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;

  const CommentsScreen({
    super.key,
    required this.post,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  final _commentService = CommentService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      await _commentService.addComment(
        postId: widget.post.id,
        location: user.location,
        userId: user.uid,
        userName: user.fullName,
        userProfilePicture: user.profilePictureUrl,
        content: _commentController.text.trim(),
      );

      _commentController.clear();
      FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: ${e.toString()}'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    try {
      await _commentService.deleteComment(
        postId: widget.post.id,
        location: user.location,
        commentId: commentId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment deleted'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comment'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Comments')),
        body: Center(child: Text('Please log in to view comments')),
      );
    }

    final borderColor = widget.post.type == 'barangay'
        ? AppColors.brightBlue
        : AppColors.goldenYellow;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Comments',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.charcoalBlack),
      ),
      body: Column(
        children: [
          // Post Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: borderColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.post.type == 'barangay'
                          ? Icons.campaign
                          : Icons.person,
                      color: borderColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.post.authorName,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoalBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.post.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: _commentService.streamComments(widget.post.id, user.location),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: borderColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading comments',
                      style: GoogleFonts.dmSans(color: Colors.grey.shade600),
                    ),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isOwnComment = comment.userId == user.uid;

                    return _buildCommentItem(comment, isOwnComment);
                  },
                );
              },
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: borderColor.withOpacity(0.2),
                    backgroundImage: user.profilePictureUrl != null
                        ? NetworkImage(user.profilePictureUrl!)
                        : null,
                    child: user.profilePictureUrl == null
                        ? Icon(Icons.person, size: 20, color: borderColor)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: GoogleFonts.dmSans(fontSize: 14),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: borderColor,
                            ),
                          )
                        : Icon(Icons.send, color: borderColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, bool isOwnComment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.goldenYellow.withOpacity(0.2),
            backgroundImage: comment.userProfilePicture != null
                ? NetworkImage(comment.userProfilePicture!)
                : null,
            child: comment.userProfilePicture == null
                ? Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.goldenYellow,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              comment.userName,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoalBlack,
                              ),
                            ),
                          ),
                          if (isOwnComment)
                            InkWell(
                              onTap: () => _showDeleteDialog(comment.id),
                              child: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: AppColors.coralRed,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        comment.content,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.charcoalBlack.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    _formatTimestamp(comment.createdAt),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Comment',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this comment?',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteComment(commentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coralRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Delete', style: GoogleFonts.dmSans()),
          ),
        ],
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
