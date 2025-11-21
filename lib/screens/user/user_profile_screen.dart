import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../screens/onboarding/login_screen.dart';
import 'personal_info_form_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                        backgroundImage: user.profilePictureUrl != null
                            ? NetworkImage(user.profilePictureUrl!)
                            : null,
                        child: user.profilePictureUrl == null
                            ? Text(
                          user.fullName[0].toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brightBlue,
                          ),
                        )
                            : null,
                      ),
                      if (user.isFullyVerified)
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

            // Complete Profile Section
            if (!user.isFullyVerified) ...[
              _buildSectionTitle('Complete Your Profile'),
              const SizedBox(height: 12),
              _buildProfileCompletionCard(user),
              const SizedBox(height: 24),
            ],

            // Profile Information
            _buildSectionTitle('Profile Information'),
            const SizedBox(height: 12),
            _buildInfoCard(user),

            const SizedBox(height: 24),

            // Location Information
            _buildSectionTitle('Location'),
            const SizedBox(height: 12),
            _buildLocationCard(user),

            const SizedBox(height: 24),

            // Personal Information (if completed)
            if (user.personalInfo != null) ...[
              _buildSectionTitle('Personal Details'),
              const SizedBox(height: 12),
              _buildPersonalInfoCard(user),
              const SizedBox(height: 24),
            ],

            // Household Members (if added)
            if (user.familyMembers.isNotEmpty) ...[
              _buildSectionTitle('Household Members'),
              const SizedBox(height: 12),
              ...user.familyMembers.map((member) => _buildFamilyMemberCard(member)),
            ],
          ],
        ),
      ),
    );
  }

  // DELETE the entire _buildPhoneVerificationCard method
// DELETE any phone verification button handlers
// DELETE references to phoneVerified in the build method

// Update the verification badge to only check profileCompleted:
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

  Widget _buildProfileCompletionCard(user) {
    final canComplete = user.verificationStatus == 'partially_verified';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: canComplete ? AppColors.lightYellow : AppColors.lightBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canComplete ? AppColors.goldenYellow : AppColors.brightBlue,
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
                  color: canComplete
                      ? AppColors.goldenYellow.withValues(alpha: 0.2)
                      : AppColors.brightBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  canComplete ? Icons.edit_note : Icons.lock_outline,
                  color: canComplete ? AppColors.goldenYellow : AppColors.brightBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  canComplete
                      ? 'Complete Your Profile'
                      : 'Waiting for Admin Approval',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            canComplete
                ? 'Fill out your personal information to unlock all features including posting and commenting.'
                : 'Your account is being reviewed by the barangay admin. You\'ll be able to complete your profile once approved.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.charcoalBlack.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          if (canComplete) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PersonalInfoFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  'Complete Profile Now',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldenYellow,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                  color: user.emailVerified
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppColors.lightRed,
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
                  color: user.emailVerified
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppColors.lightRed,
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

  Widget _buildPersonalInfoCard(user) {
    final info = user.personalInfo!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person, 'Full Name', info.fullName),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.cake,
            'Date of Birth',
            '${info.dateOfBirth.day}/${info.dateOfBirth.month}/${info.dateOfBirth.year}',
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.place, 'Place of Birth', info.placeOfBirth),
          const Divider(height: 24),
          _buildInfoRow(Icons.home, 'Current Address', info.currentAddress),
          if (info.is4PsRecipient) ...[
            const Divider(height: 24),
            _buildInfoRow(Icons.family_restroom, '4Ps Status', 'Recipient'),
          ],
          if (info.isIndigenousPeople) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.groups,
              'Indigenous Group',
              info.indigenousPeopleGroup ?? 'N/A',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.lightBlue,
          child: Text(
            member.firstName[0].toUpperCase(),
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              color: AppColors.brightBlue,
            ),
          ),
        ),
        title: Text(
          member.fullName,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${member.relationship.toUpperCase()} • ${member.dateOfBirth.day}/${member.dateOfBirth.month}/${member.dateOfBirth.year}',
          style: GoogleFonts.dmSans(fontSize: 12),
        ),
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