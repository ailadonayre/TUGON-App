import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import 'residency_check_screen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedBarangay;

  List<String> _provinces = [];
  List<String> _cities = [];
  List<String> _barangays = [];

  @override
  void initState() {
    super.initState();
    _provinces = LocationService.getProvinces();
  }

  void _onProvinceChanged(String? value) {
    setState(() {
      _selectedProvince = value;
      _selectedCity = null;
      _selectedBarangay = null;
      _cities = value != null ? LocationService.getCities(value) : [];
      _barangays = [];
    });
  }

  void _onCityChanged(String? value) {
    setState(() {
      _selectedCity = value;
      _selectedBarangay = null;
      _barangays = (value != null && _selectedProvince != null)
          ? LocationService.getBarangays(_selectedProvince!, value)
          : [];
    });
  }

  void _onBarangayChanged(String? value) {
    setState(() {
      _selectedBarangay = value;
    });
  }

  void _continue() {
    if (_selectedProvince != null &&
        _selectedCity != null &&
        _selectedBarangay != null) {
      Provider.of<UserProvider>(context, listen: false).setLocation(
        _selectedProvince!,
        _selectedCity!,
        _selectedBarangay!,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ResidencyCheckScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedProvince != null &&
        _selectedCity != null &&
        _selectedBarangay != null;

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
                'Select Your Location',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step 1 of 4',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.25,
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
                      Text(
                        'Please select your barangay to continue with registration.',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildDropdown(
                        label: 'Province',
                        hint: 'Select province',
                        value: _selectedProvince,
                        items: _provinces,
                        onChanged: _onProvinceChanged,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        label: 'Municipality / City',
                        hint: 'Select municipality or city',
                        value: _selectedCity,
                        items: _cities,
                        onChanged: _onCityChanged,
                        enabled: _selectedProvince != null,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        label: 'Barangay',
                        hint: 'Select barangay',
                        value: _selectedBarangay,
                        items: _barangays,
                        onChanged: _onBarangayChanged,
                        enabled: _selectedCity != null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Continue',
                onPressed: canContinue ? _continue : () {},
                color: canContinue ? AppColors.warmOrange : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.softBlack,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(hint),
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: InputBorder.none,
            ),
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: AppColors.softBlack,
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}