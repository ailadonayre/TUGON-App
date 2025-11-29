import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import 'user_hotlines_screen.dart';
import 'submit_report_screen.dart';
import 'user_reports_tracker_screen.dart';
import 'request_document_screen.dart';
import 'user_profile_screen.dart';


class UserHomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const UserHomeScreen({super.key, this.onProfileTap});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final barangayId = user?.location.toDocumentId() ?? '';

    // Debug logging
    print('🔍 DEBUG: User: ${user?.fullName}');
    print('🔍 DEBUG: BarangayId: $barangayId');
    print('🔍 DEBUG: Location: ${user?.location.barangay}, ${user?.location.city}, ${user?.location.province}');

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // App Bar with Logo
          Container(
            color: AppColors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Logo Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/logo/TUGON_Logo-lowercase-v2.png',
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        const Spacer(),
                        // User Profile Picture
                        GestureDetector(
                          onTap: widget.onProfileTap,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.brightBlue.withOpacity(0.2),
                            backgroundImage: user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty
                                ? NetworkImage(user.profilePictureUrl!)
                                : null,
                            child: user?.profilePictureUrl == null || user!.profilePictureUrl!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: AppColors.brightBlue,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.charcoalBlack,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                      indicatorColor: AppColors.goldenYellow,
                      indicatorWeight: 3,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Barangay'),
                        Tab(text: 'Community'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBarangayTab(context, user, barangayId),
                _buildCommunityTab(context, user, barangayId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangayTab(BuildContext context, dynamic user, String barangayId) {
    return CustomScrollView(
      slivers: [
        // Quick Access Menu
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickAccessCard(
                  context,
                  'Emergency\nHotlines',
                  Icons.phone_in_talk,
                  AppColors.coralRed,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserHotlinesScreen(),
                    ),
                  ),
                ),
                _buildQuickAccessCard(
                  context,
                  'Submit\nReport',
                  Icons.report,
                  AppColors.brightBlue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubmitReportScreen(),
                    ),
                  ),
                ),
                _buildQuickAccessCard(
                  context,
                  'Request\nDocument',
                  Icons.document_scanner_rounded,
                  Colors.deepPurple.shade400,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RequestDocumentScreen(),
                    ),
                  ),
                ),
                _buildQuickAccessCard(
                  context,
                  'My\nTracker',
                  Icons.history,
                  Colors.green.shade600,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserReportsTrackerScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Barangay Posts (Real-time)
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('barangays')
              .doc(barangayId)
              .collection('posts')
              .where('type', isEqualTo: 'barangay')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lightRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Error loading posts', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.coralRed)),
                      SizedBox(height: 8),
                      Text('${snapshot.error}', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.charcoalBlack)),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('No announcements yet', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoalBlack)),
                  ),
                ),
              );
            }

            final posts = snapshot.data!.docs.map((doc) {
              return PostModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

            posts.sort((a, b) {
              if (a.isCritical != b.isCritical) {
                return a.isCritical ? -1 : 1;
              }
              if (a.pinned != b.pinned) {
                return a.pinned ? -1 : 1;
              }
              return b.createdAt.compareTo(a.createdAt);
            });

            final hasCritical = posts.any((p) => p.isCritical);

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return PostCard(post: post, isPinned: post.pinned);
                },
                childCount: posts.length,
              ),
            );
          },
        ),

        // Bottom Padding
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.bottom + 80,
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityTab(BuildContext context, dynamic user, String barangayId) {
    return CustomScrollView(
      slivers: [
        // Community Posts (Real-time)
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('barangays')
              .doc(barangayId)
              .collection('posts')
              .where('type', isEqualTo: 'community')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return SliverToBoxAdapter(
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
                            color: AppColors.charcoalBlack.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final posts = snapshot.data!.docs.map((doc) {
              return PostModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return PostCard(post: post);
                },
                childCount: posts.length,
              ),
            );
          },
        ),

        // Bottom Padding
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.bottom + 80,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - (16 * 2) - (12 * 3)) / 4;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: cardWidth > 60 ? cardWidth : 60,
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
