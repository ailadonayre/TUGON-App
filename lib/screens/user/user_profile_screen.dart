import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/family_member_form.dart';
import '../../models/family_member_model.dart';
import '../../screens/onboarding/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _streetNameController = TextEditingController();

  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName ?? '';
      _middleNameController.text = user.middleName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _placeOfBirthController.text = user.placeOfBirth ?? '';
      _houseNumberController.text = user.houseNumber ?? '';
      _streetNameController.text = user.streetName ?? '';
      _selectedDob = user.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _placeOfBirthController.dispose();
    _houseNumberController.dispose();
    _streetNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDob ?? DateTime(now.year - 20, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 120),
      lastDate: DateTime(now.year - 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.goldenYellow),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    final success = await profileProvider.updateProfile(
      uid: authProvider.currentUser!.uid,
      location: authProvider.currentUser!.location,
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _selectedDob!,
      placeOfBirth: _placeOfBirthController.text.trim(),
      houseNumber: _houseNumberController.text.trim(),
      streetName: _streetNameController.text.trim(),
    );

    if (mounted) {
      if (success) {
        await authProvider.loadUserData(authProvider.currentUser!.email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.error ?? 'Failed to update profile'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    final success = await profileProvider.uploadProfilePicture(
      authProvider.currentUser!.uid,
      authProvider.currentUser!.location,
    );

    if (mounted) {
      if (success) {
        await authProvider.loadUserData(authProvider.currentUser!.email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload picture'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    }
  }

  void _showAddFamilyMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => FamilyMemberFormDialog(
        onSubmit: (member) async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

          final success = await profileProvider.addFamilyMember(
            uid: authProvider.currentUser!.uid,
            location: authProvider.currentUser!.location,
            member: member,
          );

          if (mounted) {
            if (success) {
              await authProvider.loadUserData(authProvider.currentUser!.email);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Family member added!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(profileProvider.error ?? 'Failed to add member'),
                  backgroundColor: AppColors.coralRed,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.coralRed),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Sign Out'),
                  content: Text('Are you sure you want to sign out?'),
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
                      child: Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authProvider.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification Status Banner
            _buildVerificationBanner(user),

            const SizedBox(height: 24),

            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.lightYellow,
                    backgroundImage: user?.profilePictureUrl != null
                        ? NetworkImage(user!.profilePictureUrl!)
                        : null,
                    child: user?.profilePictureUrl == null
                        ? Text(
                      user?.fullName[0].toUpperCase() ?? 'U',
                      style: GoogleFonts.dmSans(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenYellow,
                      ),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _uploadProfilePicture,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.goldenYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                        ),
                        child: Icon(Icons.camera_alt, color: AppColors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Personal Information Form
            Text(
              'Personal Information',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalBlack,
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hint: 'Juan',
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _middleNameController,
                    label: 'Middle Name (Optional)',
                    hint: 'Santos',
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hint: 'Dela Cruz',
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth Picker
                  InkWell(
                    onTap: _selectDateOfBirth,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _selectedDob != null
                            ? '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}'
                            : 'Select date',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: _selectedDob != null
                              ? AppColors.charcoalBlack
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _placeOfBirthController,
                    label: 'Place of Birth',
                    hint: 'Batangas City',
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icon(Icons.location_on_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Place of birth is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Current Address
            Text(
              'Current Address',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalBlack,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _houseNumberController,
              label: 'House Number',
              hint: '123',
              prefixIcon: Icon(Icons.home_outlined),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'House number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _streetNameController,
              label: 'Street Name',
              hint: 'Main Street',
              textCapitalization: TextCapitalization.words,
              prefixIcon: Icon(Icons.signpost_outlined),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Street name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Read-only location fields
            CustomTextField(
              controller: TextEditingController(text: user?.location.barangay ?? ''),
              label: 'Barangay',
              hint: '',
              enabled: false,
              prefixIcon: Icon(Icons.place_outlined),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(text: user?.location.city ?? ''),
              label: 'City',
              hint: '',
              enabled: false,
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(text: user?.location.province ?? ''),
              label: 'Province',
              hint: '',
              enabled: false,
              prefixIcon: Icon(Icons.map_outlined),
            ),

            const SizedBox(height: 32),

            // Family Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Immediate Family',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddFamilyMemberDialog,
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenYellow,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (user?.familyMembers.isEmpty ?? true)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.lightYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No family members added yet',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.charcoalBlack.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              )
            else
              ...user!.familyMembers.map((member) => _buildFamilyMemberCard(member)),

            const SizedBox(height: 32),

            // Action Buttons
            CustomButton(
              text: 'Save Profile',
              onPressed: _saveProfile,
              isLoading: profileProvider.isLoading,
            ),

            const SizedBox(height: 12),

            CustomButton(
              text: 'Resend Email Verification',
              onPressed: () async {
                await profileProvider.resendEmailVerification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Verification email sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              isOutlined: true,
              color: AppColors.brightBlue,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBanner(user) {
    Color bannerColor;
    IconData bannerIcon;
    String bannerTitle;
    String bannerMessage;

    switch (user?.verificationStatus) {
      case 'fully_verified':
        bannerColor = Colors.green;
        bannerIcon = Icons.verified_user;
        bannerTitle = 'Fully Verified';
        bannerMessage = 'You can post to the community board';
        break;
      case 'partially_verified':
        bannerColor = AppColors.goldenYellow;
        bannerIcon = Icons.pending;
        bannerTitle = 'Partially Verified';
        bannerMessage = user?.emailVerified == false
            ? 'Please verify your email'
            : 'Please complete your profile';
        break;
      default:
        bannerColor = AppColors.coralRed;
        bannerIcon = Icons.hourglass_empty;
        bannerTitle = 'Pending Admin Approval';
        bannerMessage = 'Waiting for barangay admin approval';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerTitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: bannerColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bannerMessage,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.charcoalBlack.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(FamilyMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightBlue,
            child: Icon(
              member.relationship == 'mother' || member.relationship == 'father'
                  ? Icons.person
                  : Icons.child_care,
              color: AppColors.brightBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.relationship.toUpperCase()} • ${member.placeOfBirth}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.coralRed),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Remove Family Member'),
                  content: Text('Remove ${member.fullName}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
                      child: Text('Remove'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

                await profileProvider.removeFamilyMember(
                  uid: authProvider.currentUser!.uid,
                  location: authProvider.currentUser!.location,
                  memberId: member.id,
                );

                if (mounted) {
                  await authProvider.loadUserData(authProvider.currentUser!.email);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}