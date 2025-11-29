import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import 'pending_approvals_screen.dart';
import 'all_users_screen.dart';
import 'user_statistics_screen.dart';
import 'manage_posts_screen.dart';
import 'manage_hotlines_screen.dart';
import 'manage_reports_screen.dart';
// --- 1. IMPORT THE NEW SCREEN ---
import 'manage_appointments_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await adminProvider.loadStatistics(authProvider.currentUser!.location);
      await adminProvider.loadPendingUsers(authProvider.currentUser!.location);
    }
  }

  Future<void> _updateProfilePicture() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing...')),
    );

    try {
      await authProvider.updateUserProfilePicture();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update picture: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final stats = adminProvider.statistics;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.brightBlue),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.coralRed),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.brightBlue,
        child: SafeArea(
          bottom: false,
          child: Builder(builder: (context) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset + bottomPadding),
              children: [
                // Welcome Card, Overview, Quick Actions... (code remains the same)
                // ...
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.brightBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brightBlue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _updateProfilePicture,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.white,
                              backgroundImage: authProvider.currentUser?.profilePictureUrl != null &&
                                  authProvider.currentUser!.profilePictureUrl!.isNotEmpty
                                  ? NetworkImage(authProvider.currentUser!.profilePictureUrl!)
                                  : null,
                              child: authProvider.currentUser?.profilePictureUrl == null ||
                                  authProvider.currentUser!.profilePictureUrl!.isEmpty
                                  ? const Icon(
                                      Icons.admin_panel_settings,
                                      size: 40,
                                      color: AppColors.brightBlue,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.goldenYellow,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, Admin!',
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.currentUser?.location.barangay ?? '',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Overview header
                Text(
                  'Overview',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 16),

                // Statistics Cards (GridView inside ListView)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _buildStatCard(
                      'Total Users',
                      stats['total']?.toString() ?? '0',
                      Icons.people_rounded,
                      AppColors.brightBlue,
                    ),
                    _buildStatCard(
                      'Pending',
                      stats['pending']?.toString() ?? '0',
                      Icons.pending_actions_rounded,
                      AppColors.goldenYellow,
                    ),
                    _buildStatCard(
                      'Approved',
                      stats['approved']?.toString() ?? '0',
                      Icons.check_circle_rounded,
                      AppColors.brightBlue,
                    ),
                    _buildStatCard(
                      'Rejected',
                      stats['rejected']?.toString() ?? '0',
                      Icons.cancel_rounded,
                      AppColors.coralRed,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Quick Actions header
                Text(
                  'Quick Actions',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 16),

                _buildActionCard(
                  'Pending Approvals',
                  'Review and approve user registrations',
                  Icons.how_to_reg_rounded,
                  AppColors.goldenYellow,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PendingApprovalsScreen(),
                      ),
                    );
                  },
                  badge: adminProvider.pendingUsers.length,
                ),

                const SizedBox(height: 12),

                _buildActionCard(
                  'All Users',
                  'View and manage all registered users',
                  Icons.people_alt_rounded,
                  AppColors.brightBlue,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllUsersScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildActionCard(
                  'Statistics',
                  'View detailed user statistics',
                  Icons.bar_chart_rounded,
                  AppColors.coralRed,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserStatisticsScreen(),
                      ),
                    );
                  },
                ),


                const SizedBox(height: 32),

                // Content Management header
                Text(
                  'Content Management',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 16),

                _buildActionCard(
                  'Posts & Announcements',
                  'Manage barangay posts and announcements',
                  Icons.article_rounded,
                  AppColors.brightBlue,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManagePostsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildActionCard(
                  'Emergency Hotlines',
                  'Manage emergency contact numbers',
                  Icons.phone_in_talk_rounded,
                  AppColors.coralRed,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageHotlinesScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildActionCard(
                  'User Reports',
                  'Review and respond to user-submitted reports',
                  Icons.report_rounded,
                  AppColors.goldenYellow,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageReportsScreen(),
                      ),
                    );
                  },
                ),

                // --- 2. ADD THE NEW ACTION CARD HERE ---
                const SizedBox(height: 12),

                _buildActionCard(
                  'Document Requests',
                  'Manage appointment requests for documents',
                  Icons.document_scanner_rounded,
                  Colors.deepPurple.shade400, // Matching color
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageAppointmentsScreen(),
                      ),
                    );
                  },
                ),

                // Extra spacing at the end so the last item isn't flush to the bottom
                SizedBox(height: bottomPadding + 24),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoalBlack.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap, {
        int? badge,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoalBlack,
                        ),
                      ),
                      if (badge != null && badge > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.coralRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge.toString(),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.charcoalBlack.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
