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
          MaterialPageRoute(builder: (_) => const