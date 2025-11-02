import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import 'user_home_screen.dart';
import 'user_search_screen.dart';
import 'user_report_screen.dart';
import 'user_history_screen.dart';
import 'user_profile_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const UserSearchScreen(),
    const UserReportScreen(),
    const UserHistoryScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomAppBar(
            elevation: 0,
            color: AppColors.white,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home', AppColors.brightBlue),
                  _buildNavItem(1, Icons.search_rounded, 'Search', AppColors.goldenYellow),
                  _buildNavItem(2, Icons.add_circle_rounded, 'Report', AppColors.coralRed, isCenter: true),
                  _buildNavItem(3, Icons.history_rounded, 'History', AppColors.goldenYellow),
                  _buildNavItem(4, Icons.person_rounded, 'Profile', AppColors.brightBlue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color activeColor, {bool isCenter = false}) {
    final isSelected = _currentIndex == index;

    if (isCenter) {
      return GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppColors.primaryGradient
                : LinearGradient(
              colors: [activeColor.withOpacity(0.8), activeColor],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isSelected ? AppColors.coralRed : activeColor).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            color: AppColors.white,
            size: 32,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.grey.shade400,
              size: isSelected ? 28 : 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}