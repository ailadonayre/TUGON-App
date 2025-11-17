import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../screens/onboarding/login_screen.dart';
import 'phone_verification_modal.dart';
import '../../models/user_model.dart'; // <-- import your UserModel

class UserProfileScreen extends StatefulWidget {
  final UserModel user; // <-- add this

  const UserProfileScreen({required this.user, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _handlePhoneVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = widget.user;

    if (user == null) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PhoneVerificationModal(
        phoneNumber: user.phone,
        onVerificationComplete: (success) async {
          if (success) {
            await _firestoreService.updatePhoneVerification(
              user.uid,
              user.location,
              true,
            );
            await authProvider.loadUserData(user.email);
          }
        },
      ),
    );

    if (result == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Phone verified! Complete your profile to unlock all features.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _markProfileComplete() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = widget.user;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _firestoreService.updateProfileCompletion(
        user.uid,
        user.location,
        true,
      );

      await authProvider.loadUserData(user.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile completed!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.coralRed),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.brightBlue.withValues(alpha: 0.2),
                        child: Text(
                          user.fullName[0].toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brightBlue,
                          ),
                        ),
                      ),
                      if (user.phoneVerified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildVerificationBadge(user),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Phone Verification'),
            const SizedBox(height: 12),
            _buildPhoneVerificationCard(user),
            const SizedBox(height: 24),
            _buildSectionTitle('Profile Information'),
            const SizedBox(height: 12),
            _buildInfoCard(user),
            const SizedBox(height: 24),
            _buildSectionTitle('Location'),
            const SizedBox(height: 12),
            _buildLocationCard(user),
            const SizedBox(height: 32),
            if (user.phoneVerified && !user.profileCompleted)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _markProfileComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Complete Profile',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(user) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (user.verificationStatus == 'fully_verified') {
      badgeColor = Colors.green;
      badgeText = 'Fully Verified';
      badgeIcon = Icons.verified;
    } else if (user.verificationStatus == 'partially_verified') {
      badgeColor = AppColors.goldenYellow;
      badgeText = 'Partially Verified';
      badgeIcon = Icons.pending;
    } else {
      badgeColor = Colors.grey;
      badgeText = 'Pending Admin Approval';
      badgeIcon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.charcoalBlack,
      ),
    );
  }

  Widget _buildPhoneVerificationCard(user) {
    final isVerified = user.phoneVerified;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.withValues(alpha: 0.05) : AppColors.lightYellow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? Colors.green : AppColors.goldenYellow,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.green.withValues(alpha: 0.1) : AppColors.lightYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isVerified ? Icons.check_circle : Icons.phone_android,
                  color: isVerified ? Colors.green : AppColors.goldenYellow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      user.phone,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Verified',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          if (!isVerified) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.goldenYellow,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.verificationStatus == 'partially_verified'
                          ? 'Verify your phone to unlock all features'
                          : 'Complete admin approval first',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: user.verificationStatus == 'partially_verified'
                    ? _handlePhoneVerification
                    : null,
                icon: const Icon(Icons.sms, size: 18),
                label: Text(
                  'Send SMS Code',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brightBlue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Full Name', user.fullName),
          const Divider(height: 24),
          _buildInfoRow(Icons.email_outlined, 'Email', user.email),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_outlined, 'Phone', user.phone),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: user.emailVerified ? Colors.green.withValues(alpha: 0.1) : AppColors.lightRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  user.emailVerified ? Icons.check_circle : Icons.cancel,
                  size: 20,
                  color: user.emailVerified ? Colors.green : AppColors.coralRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Email (Registration)',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.emailVerified ? Colors.green.withValues(alpha: 0.1) : AppColors.lightRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.emailVerified ? 'Verified' : 'Not Verified',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: user.emailVerified ? Colors.green : AppColors.coralRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_city, 'Province', user.location.province),
          const Divider(height: 24),
          _buildInfoRow(Icons.location_on, 'City', user.location.city),
          const Divider(height: 24),
          _buildInfoRow(Icons.place, 'Barangay', user.location.barangay),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.brightBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
