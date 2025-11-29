import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/family_member_model.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return FutureBuilder<UserModel?>(
      future: authProvider.getUserById(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              user?.fullName ?? 'Profile',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalBlack,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData || user == null) {
                return const Center(child: Text('User not found'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: (user.profilePictureUrl != null &&
                                    user.profilePictureUrl!.isNotEmpty)
                                ? NetworkImage(user.profilePictureUrl!)
                                : null,
                            child: (user.profilePictureUrl == null ||
                                    user.profilePictureUrl!.isEmpty)
                                ? Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(user.fullName,
                              style: GoogleFonts.dmSans(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(user.email,
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          _buildVerificationBadge(user),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Profile Information'),
                    const SizedBox(height: 12),
                    _buildInfoCard(user),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Location'),
                    const SizedBox(height: 12),
                    _buildLocationCard(user),
                    const SizedBox(height: 24),
                    if (user.personalInfo != null) ...[
                      _buildSectionTitle('Personal Details'),
                      const SizedBox(height: 12),
                      _buildPersonalInfoCard(user),
                      const SizedBox(height: 24),
                    ],
                    if (user.familyMembers.isNotEmpty) ...[
                      _buildSectionTitle('Household Members'),
                      const SizedBox(height: 12),
                      ...user.familyMembers
                          .map((member) => _buildFamilyMemberCard(member)),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVerificationBadge(UserModel user) {
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
        color: badgeColor.withOpacity(0.1),
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

  Widget _buildInfoCard(UserModel user) {
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
                      ? Colors.green.withOpacity(0.1)
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
                      ? Colors.green.withOpacity(0.1)
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

  Widget _buildLocationCard(UserModel user) {
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

  Widget _buildPersonalInfoCard(UserModel user) {
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

  Widget _buildFamilyMemberCard(FamilyMember member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.lightBlue,
          child: Text(
            member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : '?',
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
