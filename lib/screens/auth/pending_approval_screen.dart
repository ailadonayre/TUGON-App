import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/login_screen.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.lightYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_outlined,
                  size: 100,
                  color: AppColors.goldenYellow,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Almost There!',
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Your registration is under review',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.person_outline,
                      'Name',
                      user?.fullName ?? 'N/A',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Barangay',
                      user?.location.barangay ?? 'N/A',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Phone',
                      user?.phone ?? 'N/A',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.brightBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Your account is being reviewed by your barangay council. You will receive an SMS notification within 24–48 hours.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.charcoalBlack,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Done',
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
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.brightBlue, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: AppColors.charcoalBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}