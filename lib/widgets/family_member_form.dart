import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../models/family_member_model.dart';

class FamilyMemberFormDialog extends StatefulWidget {
  final Function(FamilyMember) onSubmit;

  const FamilyMemberFormDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<FamilyMemberFormDialog> createState() => _FamilyMemberFormDialogState();
}

class _FamilyMemberFormDialogState extends State<FamilyMemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

  String? _selectedRelationship;
  DateTime? _selectedDob;

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
    final initialDate = _selectedDob ?? DateTime(now.year - 10, now.month, now.day);

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
      setState(() => _selectedDob = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }
    if (_selectedRelationship == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select relationship'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    final member = FamilyMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _selectedDob!,
      placeOfBirth: _placeOfBirthController.text.trim(),
      relationship: _selectedRelationship!,
    );

    widget.onSubmit(member);
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
                  'Add Family Member',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Juan',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _middleNameController,
                  label: 'Middle Name (Optional)',
                  hint: 'Santos',
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Dela Cruz',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Date of Birth Picker
                InkWell(
                  onTap: _selectDateOfBirth,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
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

                const SizedBox(height: 12),
                CustomTextField(
                  controller: _placeOfBirthController,
                  label: 'Place of Birth',
                  hint: 'Batangas City',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Relationship Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRelationship,
                  decoration: InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: FamilyMember.validRelationships.map((rel) {
                    return DropdownMenuItem(
                      value: rel,
                      child: Text(rel.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedRelationship = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select relationship';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
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