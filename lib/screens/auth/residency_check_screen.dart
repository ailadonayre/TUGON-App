import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../providers/user_provider.dart';
import 'verification_required_screen.dart';
import 'registration_form_screen.dart';

class ResidencyCheckScreen extends StatefulWidget {
  const ResidencyCheckScreen({super.key});

  @override
  State<ResidencyCheckScreen> createState() => _ResidencyCheckScreenState();
}

class _ResidencyCheckScreenState extends State<ResidencyCheckScreen> {
  bool _isRegisteredResident = false;

  void _continue() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setResidencyStatus(_isRegisteredResident);

    if (_isRegisteredResident) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RegistrationFormScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const VerificationRequiredScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.softBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Residency Check',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step 2 of 4',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.warmOrange,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.goldenYellow
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.goldenYellow
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.goldenYellow
                                  .withValues(alpha: 0.8),
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'To proceed with registration, you must be a registered resident of the selected barangay.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.softBlack,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Are you already a registered resident of this barangay?',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softBlack,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildResidencyOption(
                        value: true,
                        title: 'Yes, I am a registered resident',
                        subtitle:
                        'I have valid proof of residency and am registered in this barangay',
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildResidencyOption(
                        value: false,
                        title: 'No, I am not yet registered',
                        subtitle:
                        'I need to complete residency verification requirements first',
                        icon: Icons.pending_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Continue',
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResidencyOption({
    required bool value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _isRegisteredResident == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isRegisteredResident = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.warmOrange.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.warmOrange
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.warmOrange
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.softBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.warmOrange,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}