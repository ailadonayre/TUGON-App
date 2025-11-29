import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../screens/user/other_user_profile_screen.dart';
import '../../utils/colors.dart';
import '../../models/post_model.dart';
import '../../models/reaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/reaction_service.dart';
import '../../services/comment_service.dart';
import '../../screens/user/comments_screen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isPinned;

  const PostCard({
    super.key,
    required this.post,
    this.isPinned = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final reactionService = ReactionService();
    final commentService = CommentService();

    final isBarangay = post.type == 'barangay';
    final borderColor = post.isCritical
        ? AppColors.coralRed
        : isBarangay
            ? AppColors.brightBlue
            : AppColors.goldenYellow;

    final canInteract = user?.isFullyVerified ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.3),
          width: post.isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () {
              if (!isBarangay) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtherUserProfileScreen(userId: post.authorId),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: borderColor.withOpacity(0.2),
                    backgroundImage: !isBarangay &&
                            post.authorProfilePicture != null &&
                            post.authorProfilePicture!.isNotEmpty
                        ? NetworkImage(post.authorProfilePicture!)
                        : null,
                    child: (isBarangay ||
                            post.authorProfilePicture == null ||
                            post.authorProfilePicture!.isEmpty)
                        ? Icon(
                            isBarangay ? Icons.campaign : Icons.person,
                            color: borderColor,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                post.authorName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoalBlack,
                                ),
                              ),
                            ),
                            if (isPinned || post.pinned)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: borderColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.push_pin,
                                      size: 12,
                                      color: borderColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PINNED',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: borderColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: borderColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isBarangay ? 'BARANGAY' : 'COMMUNITY',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: borderColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimestamp(post.createdAt),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (post.isCritical) ...[
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.coralRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        post.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoalBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.content,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.charcoalBlack.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // Show full screen image
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.black,
                          insetPadding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              Center(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    post.imageUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 400,
                        ),
                        child: Image.network(
                          post.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppColors.brightBlue,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load image',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Reaction Bar
          if (user != null)
            StreamBuilder<PostReactionStats>(
              stream: reactionService.streamReactionStats(
                post.id,
                user.location,
                user.uid,
              ),
              builder: (context, snapshot) {
                final stats = snapshot.data ??
                    PostReactionStats(upvotes: 0, downvotes: 0);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // --- THIS IS THE FIX ---
                      // Group the two reaction buttons together in their own Row.
                      Row(
                        children: [
                          // Upvote Button
                          _buildReactionButton(
                            icon: Icons.arrow_upward_rounded,
                            count: stats.upvotes,
                            isActive: stats.userReaction == 'upvote',
                            activeColor: AppColors.brightBlue,
                            enabled: canInteract,
                            onTap: canInteract
                                ? () => reactionService.toggleUpvote(
                                      post.id,
                                      user.uid,
                                      user.location,
                                    )
                                : () => _showVerificationRequired(context),
                          ),
                          const SizedBox(width: 16), // Space between upvote and downvote
                          // Downvote Button
                          _buildReactionButton(
                            icon: Icons.arrow_downward_rounded,
                            count: stats.downvotes,
                            isActive: stats.userReaction == 'downvote',
                            activeColor: AppColors.coralRed,
                            enabled: canInteract,
                            onTap: canInteract
                                ? () => reactionService.toggleDownvote(
                                      post.id,
                                      user.uid,
                                      user.location,
                                    )
                                : () => _showVerificationRequired(context),
                          ),
                        ],
                      ),
                      const Spacer(), // This pushes the comment icon to the right

                      // Comment section with real-time count
                      if (user != null)
                        StreamBuilder<int>(
                          stream: commentService.streamCommentCount(post.id, user.location),
                          builder: (context, snapshot) {
                            final commentCount = snapshot.data ?? 0;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CommentsScreen(post: post),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      commentCount.toString(),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: commentCount > 0
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color activeColor,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? activeColor
                  : enabled
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? activeColor
                    : enabled
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Complete your profile to interact with posts',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: AppColors.goldenYellow,
        action: SnackBarAction(
          label: 'Profile',
          textColor: AppColors.white,
          onPressed: () {
            // Navigate to profile tab - handled by parent
          },
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
