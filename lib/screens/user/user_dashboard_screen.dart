import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/responsive.dart';
import '../../providers/auth_provider.dart';
import 'user_home_screen.dart';
import 'user_search_screen.dart';
import 'user_notification_screen.dart';
import 'user_profile_screen.dart';
import 'create_post_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _currentIndex = 0;

  // Screens list - current user is fetched dynamically inside each screen if needed
  List<Widget> _screens() => const [
    UserHomeScreen(),
    UserSearchScreen(),
    UserNotificationScreen(),
    UserProfileScreen(), // No 'user' parameter
  ];

  void _onCreatePost() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.isFullyVerified != true) {
      _showVerificationRequiredDialog();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreatePostScreen()),
      );
    }
  }

  void _showVerificationRequiredDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    String message;
    String statusLabel;

    if (user?.status == 'pending_review') {
      statusLabel = 'Pending Admin Approval';
      message =
      'Your account is awaiting approval from the barangay admin. You will be able to post once your account is approved.';
    } else if (user?.status == 'rejected') {
      statusLabel = 'Account Rejected';
      message =
      'Your account registration was rejected. Please contact your barangay office for more information.';
    } else if (user?.verificationStatus == 'partially_verified') {
      statusLabel = 'Profile Incomplete';
      message =
      'Please complete your profile information to unlock all features including posting, commenting, submitting reports, and requesting documents.';
    } else {
      statusLabel = 'Verification Required';
      message =
      'Complete your profile verification to unlock all features including posting, commenting, submitting reports, and requesting documents.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.coralRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3); // Go to profile tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldenYellow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
                user?.status == 'pending_review' ? 'View Status' : 'Go to Profile',
                style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens()[_currentIndex],
      floatingActionButton: _buildCenterPostButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCenterPostButton() {
    final responsive = Responsive(context);
    final buttonSize = responsive.iconSize(60);
    final iconSize = responsive.iconSize(32);

    return GestureDetector(
      onTap: _onCreatePost,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppColors.goldenYellow, // solid color
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.goldenYellow.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: iconSize),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final responsive = Responsive(context);
    final borderRadius = responsive.radius(24);
    final navHeight = responsive.spacing(65);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        child: BottomAppBar(
          elevation: 0,
          color: AppColors.white,
          padding: EdgeInsets.zero,
          child: SafeArea(
            child: SizedBox(
              height: navHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home', AppColors.goldenYellow),
                  _buildNavItem(1, Icons.search_rounded, 'Search', AppColors.goldenYellow),
                  const SizedBox(width: 70), // Space for center button
                  _buildNavItem(2, Icons.notifications_rounded, 'Notifs', AppColors.goldenYellow),
                  _buildNavItem(3, Icons.person_rounded, 'Profile', AppColors.goldenYellow),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color activeColor) {
    final responsive = Responsive(context);
    final isSelected = _currentIndex == index;

    return Flexible(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? responsive.spacing(12) : responsive.spacing(8),
            vertical: responsive.spacing(6),
          ),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(responsive.radius(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey.shade400,
                size: responsive.iconSize(isSelected ? 26 : 24),
              ),
              SizedBox(height: responsive.spacing(2)),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: responsive.sp(10),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? activeColor : Colors.grey.shade400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}