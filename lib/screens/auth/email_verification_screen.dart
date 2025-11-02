import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import 'pending_approval_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _pinController = TextEditingController();

  String? _verificationCode;
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
      if (!mounted) {
        timer.cancel();
        return;
      }
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
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email = userProvider.registrationData['email'] ?? '';

    try {
      final code = await authProvider.sendVerificationCode(email);

      if (code != null) {
        setState(() {
          _verificationCode = code;
          _isLoading = false;
        });
        _startResendTimer();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Verification code sent to your email!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    }
  }

  // DEVELOPMENT ONLY - Show code in dialog
  // Remove this in production
  void _showCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Development Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your verification code is:'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brightBlue,
                  letterSpacing: 8,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'In production, this will be sent to your email.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (_pinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a 6-digit code'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email = userProvider.registrationData['email'] ?? '';

    try {
      final isValid = await authProvider.verifyEmailCode(email, _pinController.text);

      if (isValid) {
        // Create user in Firestore
        final userData = UserModel(
          uid: authProvider.firebaseUser!.uid,
          fullName: userProvider.registrationData['fullName'] ?? '',
          email: email,
          phone: userProvider.registrationData['phone'] ?? '',
          location: userProvider.location!,
          status: 'pending_review',
          phoneVerified: false,
          emailVerified: true,
          createdAt: DateTime.now(),
        );

        final success = await authProvider.createUserInFirestore(userData);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Email verified successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => PendingApprovalScreen(),
              ),
                  (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error ?? 'Failed to create user'),
                backgroundColor: AppColors.coralRed,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Invalid or expired code'),
              backgroundColor: AppColors.coralRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final email = userProvider.registrationData['email'] ?? '';

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoalBlack,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalBlack),
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
                'Verify Your Email',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalBlack,
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
                  AppColors.brightBlue,
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
                          color: AppColors.lightBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          size: 60,
                          color: AppColors.brightBlue,
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
                        email,
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoalBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Pinput(
                        controller: _pinController,
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(
                              color: AppColors.brightBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme,
                        errorPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: AppColors.coralRed),
                          ),
                        ),
                        onCompleted: (pin) => _verifyCode(),
                      ),
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const CircularProgressIndicator(
                          color: AppColors.brightBlue,
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
                              color: AppColors.brightBlue,
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