import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await postProvider.loadAllPosts(authProvider.currentUser!.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        color: AppColors.brightBlue,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'TUGON',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.goldenYellow.withValues(alpha: 0.1),
                        AppColors.white,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Welcome Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brightBlue.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user?.location.barangay ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Critical Announcements
            if (postProvider.barangayPosts.any((p) => p.isCritical))
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightRed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.coralRed, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.coralRed, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CRITICAL ADVISORY',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.coralRed,
                              ),
                            ),
                            Text(
                              'Tap to view important announcements',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.charcoalBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Barangay Posts Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.campaign_rounded, color: AppColors.brightBlue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Barangay Announcements',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned Barangay Posts
            if (postProvider.pinnedBarangayPosts.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final post = postProvider.pinnedBarangayPosts[index];
                    return PostCard(post: post, isPinned: true);
                  },
                  childCount: postProvider.pinnedBarangayPosts.length,
                ),
              ),

            // Regular Barangay Posts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final post = postProvider.regularBarangayPosts[index];
                  return PostCard(post: post);
                },
                childCount: postProvider.regularBarangayPosts.length,
              ),
            ),

            // Community Posts Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.people_rounded, color: AppColors.goldenYellow, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Community Posts',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Community Posts List
            if (postProvider.communityPosts.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.forum_outlined, size: 48, color: AppColors.goldenYellow),
                        SizedBox(height: 12),
                        Text(
                          'No community posts yet',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Be the first to share with your community!',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.charcoalBlack.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final post = postProvider.communityPosts[index];
                    return PostCard(post: post);
                  },
                  childCount: postProvider.communityPosts.length,
                ),
              ),

            // Bottom Padding
            SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}