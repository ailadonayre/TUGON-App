import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/family_member_model.dart';
import '../../widgets/custom_button.dart';

class PersonalInfoFormScreen extends StatefulWidget {
  const PersonalInfoFormScreen({super.key});

  @override
  State<PersonalInfoFormScreen> createState() => _PersonalInfoFormScreenState();
}

class _PersonalInfoFormScreenState extends State<PersonalInfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Personal Info Controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _indigenousGroupController = TextEditingController();

  bool _noMiddleName = false;
  bool _noSuffix = false;
  bool _is4PsRecipient = false;
  bool _isIndigenousPeople = false;
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  // Household Members
  List<FamilyMember> _householdMembers = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.personalInfo != null) {
      final info = user!.personalInfo!;
      setState(() {
        _firstNameController.text = info.firstName;
        _middleNameController.text = info.middleName ?? '';
        _lastNameController.text = info.lastName;
        _suffixController.text = info.suffix ?? '';
        _placeOfBirthController.text = info.placeOfBirth;
        _currentAddressController.text = info.currentAddress;
        _indigenousGroupController.text = info.indigenousPeopleGroup ?? '';
        _dateOfBirth = info.dateOfBirth;
        _noMiddleName = info.middleName == null || info.middleName!.isEmpty;
        _noSuffix = info.suffix == null || info.suffix!.isEmpty;
        _is4PsRecipient = info.is4PsRecipient;
        _isIndigenousPeople = info.isIndigenousPeople;
      });
    }

    if (user?.familyMembers != null) {
      setState(() {
        _householdMembers = List.from(user!.familyMembers);
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    _placeOfBirthController.dispose();
    _currentAddressController.dispose();
    _indigenousGroupController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 120),
      lastDate: now,
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
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _addHouseholdMember() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _HouseholdMemberDialog(),
    );

    if (result != null) {
      final member = FamilyMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: result['firstName'],
        middleName: result['middleName'],
        lastName: result['lastName'],
        dateOfBirth: result['dateOfBirth'],
        placeOfBirth: result['placeOfBirth'],
        relationship: result['relationship'],
      );

      setState(() {
        _householdMembers.add(member);
      });
    }
  }

  void _removeHouseholdMember(String id) {
    setState(() {
      _householdMembers.removeWhere((m) => m.id == id);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    if (_isIndigenousPeople && _indigenousGroupController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please specify your indigenous people group'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      final personalInfo = PersonalInformation(
        firstName: _firstNameController.text.trim(),
        middleName: _noMiddleName ? null : _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        suffix: _noSuffix ? null : _suffixController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        placeOfBirth: _placeOfBirthController.text.trim(),
        homeProvince: user.location.province,
        homeCity: user.location.city,
        homeBarangay: user.location.barangay,
        currentAddress: _currentAddressController.text.trim(),
        is4PsRecipient: _is4PsRecipient,
        isIndigenousPeople: _isIndigenousPeople,
        indigenousPeopleGroup: _isIndigenousPeople ? _indigenousGroupController.text.trim() : null,
      );

      // Update user with personal info and household members
      await _firestoreService.updatePersonalInfo(
        user.uid,
        user.location,
        personalInfo,
        _householdMembers,
      );

      // Update verification status to fully_verified
      await _firestoreService.updateVerificationStatus(
        user.uid,
        user.location,
        'fully_verified',
      );

      // Reload user data
      await authProvider.loadUserData(user.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Profile completed! You now have full access.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightYellow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.goldenYellow.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.goldenYellow),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Complete this form to unlock all features including posting and commenting.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Personal Information
            Text(
              'Personal Information',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalBlack,
              ),
            ),
            const SizedBox(height: 16),

            // First Name
            TextFormField(
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'First Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Middle Name
            TextFormField(
              controller: _middleNameController,
              textCapitalization: TextCapitalization.words,
              enabled: !_noMiddleName,
              decoration: InputDecoration(
                labelText: 'Middle Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: _noMiddleName ? Colors.grey.shade200 : Colors.grey.shade50,
              ),
            ),
            CheckboxListTile(
              title: Text('No middle name', style: GoogleFonts.dmSans(fontSize: 14)),
              value: _noMiddleName,
              onChanged: (value) {
                setState(() {
                  _noMiddleName = value ?? false;
                  if (_noMiddleName) _middleNameController.clear();
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Last Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Suffix
            TextFormField(
              controller: _suffixController,
              textCapitalization: TextCapitalization.characters,
              enabled: !_noSuffix,
              decoration: InputDecoration(
                labelText: 'Suffix (Jr., Sr., III, etc.)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: _noSuffix ? Colors.grey.shade200 : Colors.grey.shade50,
              ),
            ),
            CheckboxListTile(
              title: Text('N/A', style: GoogleFonts.dmSans(fontSize: 14)),
              value: _noSuffix,
              onChanged: (value) {
                setState(() {
                  _noSuffix = value ?? false;
                  if (_noSuffix) _suffixController.clear();
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Date of Birth
            InkWell(
              onTap: _selectDateOfBirth,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateOfBirth != null
                          ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                          : 'Select date',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: _dateOfBirth != null
                            ? AppColors.charcoalBlack
                            : Colors.grey.shade400,
                      ),
                    ),
                    Icon(Icons.calendar_today, size: 20, color: AppColors.goldenYellow),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Place of Birth
            TextFormField(
              controller: _placeOfBirthController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Place of Birth *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Section: Address
            Text(
              'Home Address',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pre-filled from registration (cannot be changed)',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Province (pre-filled, disabled)
            TextFormField(
              initialValue: user.location.province,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Province',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),

            // City (pre-filled, disabled)
            TextFormField(
              initialValue: user.location.city,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'City/Municipality',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),

            // Barangay (pre-filled, disabled)
            TextFormField(
              initialValue: user.location.barangay,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Barangay',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 24),

            // Current Address
            Text(
              'Current Address',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalBlack,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _currentAddressController,
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Full Current Address *',
                hintText: 'House No., Street, Subdivision, etc.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Section: Additional Information
            Text(
              'Additional Information',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalBlack,
              ),
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: Text(
                'I am a 4Ps recipient',
                style: GoogleFonts.dmSans(fontSize: 14),
              ),
              value: _is4PsRecipient,
              onChanged: (value) {
                setState(() => _is4PsRecipient = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            CheckboxListTile(
              title: Text(
                'I am a member of an Indigenous Peoples (IPs) group',
                style: GoogleFonts.dmSans(fontSize: 14),
              ),
              value: _isIndigenousPeople,
              onChanged: (value) {
                setState(() => _isIndigenousPeople = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            if (_isIndigenousPeople) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _indigenousGroupController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Specify Indigenous Group *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Section: Household Members
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Household Members',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addHouseholdMember,
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Add Member'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.goldenYellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_householdMembers.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No household members added yet',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              ..._householdMembers.map((member) => _buildHouseholdMemberCard(member)),

            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: 'Complete Profile',
              onPressed: _submitForm,
              isLoading: _isLoading,
              color: AppColors.goldenYellow,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdMemberCard(FamilyMember member) {
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
          '${member.relationship.toUpperCase()} • Born: ${member.dateOfBirth.day}/${member.dateOfBirth.month}/${member.dateOfBirth.year}',
          style: GoogleFonts.dmSans(fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: AppColors.coralRed),
          onPressed: () => _removeHouseholdMember(member.id),
        ),
      ),
    );
  }
}

class _HouseholdMemberDialog extends StatefulWidget {
  @override
  State<_HouseholdMemberDialog> createState() => _HouseholdMemberDialogState();
}

class _HouseholdMemberDialogState extends State<_HouseholdMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

  bool _noMiddleName = false;
  String? _relationship;
  DateTime? _dateOfBirth;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _placeOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _dateOfBirth ?? DateTime(now.year - 10, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 120),
      lastDate: now,
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
      setState(() => _dateOfBirth = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    if (_relationship == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select relationship'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'firstName': _firstNameController.text.trim(),
      'middleName': _noMiddleName ? null : _middleNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'dateOfBirth': _dateOfBirth!,
      'placeOfBirth': _placeOfBirthController.text.trim(),
      'relationship': _relationship!,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                  'Add Household Member',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'First Name *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Middle Name
                TextFormField(
                  controller: _middleNameController,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_noMiddleName,
                  decoration: InputDecoration(
                    labelText: 'Middle Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                CheckboxListTile(
                  title: Text('No middle name', style: GoogleFonts.dmSans(fontSize: 13)),
                  value: _noMiddleName,
                  onChanged: (value) {
                    setState(() {
                      _noMiddleName = value ?? false;
                      if (_noMiddleName) _middleNameController.clear();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Date of Birth
                InkWell(
                  onTap: _selectDateOfBirth,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateOfBirth != null
                              ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                              : 'Select date',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: _dateOfBirth != null
                                ? AppColors.charcoalBlack
                                : Colors.grey.shade400,
                          ),
                        ),
                        Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Place of Birth
                TextFormField(
                  controller: _placeOfBirthController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Place of Birth *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Relationship
                DropdownButtonFormField<String>(
                  value: _relationship,
                  decoration: InputDecoration(
                    labelText: 'Relationship to you *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: FamilyMember.validRelationships.map((rel) {
                    return DropdownMenuItem(
                      value: rel,
                      child: Text(rel.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _relationship = value),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                    children: [
                Expanded(
                child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldenYellow,
                          ),
                          child: Text('Add'),
                        ),
                      ),
                    ],
                ),
                  ],
                ),
            ),
          ),
        ),
    );
  }
}