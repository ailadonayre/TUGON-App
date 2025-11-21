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
// This import remains user_reports_tracker_screen.dart as requested
import 'user_reports_tracker_screen.dart';
import 'request_document_screen.dart';


class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
      body: CustomScrollView(
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
                  color: AppColors.goldenYellow, // solid color only
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
                color: AppColors.goldenYellow,
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
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- QUICK ACCESS MENU (UPDATED) ---
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  // THIS BUTTON NOW NAVIGATES TO THE UNIFIED TRACKER
                  _buildQuickAccessCard(
                    context,
                    'My\nTracker', // New Label
                    Icons.history, // New Icon
                    Colors.green.shade600,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        // This now points to the modified, unified screen
                        builder: (_) => const UserReportsTrackerScreen(),
                      ),
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
                    if (index == 0 && hasCritical) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
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
                                        'See critical posts below',
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
                          PostCard(post: posts[index], isPinned: posts[index].pinned),
                        ],
                      );
                    }
                    final post = posts[index];
                    return PostCard(post: post, isPinned: post.pinned);
                  },
                  childCount: posts.length,
                ),
              );
            },
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

          // Bottom Padding - enough to clear bottom navigation bar
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 80,
            ),
          ),
        ],
      ),
    );
  }

  // This widget remains unchanged and correctly supports the 4-item layout
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
