import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'pending_approval_screen.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const SmsVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final _pinController = TextEditingController();
  final _authService = AuthService();

  String? _verificationId;
  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.verifyPhoneNumber(
        widget.phoneNumber,
            (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
          _startResendTimer();
        },
            (error) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_pinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification session expired. Please resend code.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Link phone credential to current user
      await _authService.linkPhoneCredential(
        _verificationId!,
        _pinController.text,
      );

      // Create user in Firestore
      final userData = UserModel(
        uid: authProvider.firebaseUser!.uid,
        fullName: userProvider.registrationData['fullName'] ?? '',
        email: userProvider.registrationData['email'] ?? '',
        phone: userProvider.registrationData['phone'] ?? '',
        location: userProvider.location!,
        status: 'pending_review',
        phoneVerified: true,
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      final success = await authProvider.createUserInFirestore(userData);

      if (mounted) {
        if (success) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const PendingApprovalScreen(),
            ),
                (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Failed to create user'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = widget.phoneNumber.isNotEmpty
        ? '${widget.phoneNumber.substring(0, 4)}****${widget.phoneNumber.substring(8)}'
        : '';

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.softBlack,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

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
                'Verify Phone Number',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step 4 of 4',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.warmOrange,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.warmOrange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sms_outlined,
                          size: 60,
                          color: AppColors.warmOrange,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'We sent a code to',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        maskedPhone,
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softBlack,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Pinput(
                        controller: _pinController,
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(
                              color: AppColors.warmOrange,
                              width: 2,
                            ),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme,
                        errorPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: Colors.red),
                          ),
                        ),
                        onCompleted: (pin) => _verifyCode(),
                      ),
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const CircularProgressIndicator(
                          color: AppColors.warmOrange,
                        )
                      else if (!_canResend)
                        Text(
                          'Resend code in $_resendTimer seconds',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _sendVerificationCode,
                          child: Text(
                            'Resend Code',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warmOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Verify',
                onPressed: _verifyCode,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}