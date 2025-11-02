import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  Future<void> _updateStatus(
      BuildContext context,
      String newStatus,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Action'),
        content: Text(
          'Change status to ${newStatus.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coralRed,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      try {
        if (newStatus == 'approved') {
          await adminProvider.approveUser(
            user.uid,
            authProvider.currentUser!.location,
          );
        } else if (newStatus == 'rejected') {
          await adminProvider.rejectUser(
            user.uid,
            authProvider.currentUser!.location,
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to update status'),
              backgroundColor: AppColors.coralRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (user.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.coralRed;
        statusIcon = Icons.cancel;
        break;
      case 'pending_review':
        statusColor = AppColors.goldenYellow;
        statusIcon = Icons.pending_actions;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Details',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoalBlack),
      ),
      backgroundColor: AppColors.lightBlue,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brightBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.white,
                    child: Text(
                      user.fullName[0].toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brightBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: AppColors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          user.status.toUpperCase().replaceAll('_', ' '),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Information
            _buildSection(
              'Contact Information',
              [
                _buildInfoTile(Icons.email, 'Email', user.email),
                _buildInfoTile(Icons.phone, 'Phone', user.phone),
              ],
            ),

            const SizedBox(height: 16),

            // Location Information
            _buildSection(
              'Location',
              [
                _buildInfoTile(Icons.location_city, 'Province', user.location.province),
                _buildInfoTile(Icons.location_on, 'City', user.location.city),
                _buildInfoTile(Icons.place, 'Barangay', user.location.barangay),
              ],
            ),

            const SizedBox(height: 16),

            // Verification Status
            _buildSection(
              'Verification Status',
              [
                _buildVerificationTile('Email Verified', user.emailVerified),
                _buildVerificationTile('Phone Verified', user.phoneVerified),
              ],
            ),

            const SizedBox(height: 16),

            // Account Information
            _buildSection(
              'Account Information',
              [
                _buildInfoTile(
                  Icons.calendar_today,
                  'Registered',
                  _formatDate(user.createdAt),
                ),
                _buildInfoTile(
                  Icons.admin_panel_settings,
                  'Admin',
                  user.isAdmin ? 'Yes' : 'No',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (user.status == 'pending_review') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateStatus(context, 'rejected'),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.coralRed,
                        side: const BorderSide(color: AppColors.coralRed, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(context, 'approved'),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalBlack,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.lightBlue),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
                const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildVerificationTile(String label, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green.withValues(alpha: 0.1) : AppColors.lightRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isVerified ? Icons.check_circle : Icons.cancel,
              size: 20,
              color: isVerified ? Colors.green : AppColors.coralRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.charcoalBlack,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppColors.lightRed,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isVerified ? Colors.green : AppColors.coralRed,
                width: 1,
              ),
            ),
            child: Text(
              isVerified ? 'Verified' : 'Not Verified',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isVerified ? Colors.green : AppColors.coralRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}