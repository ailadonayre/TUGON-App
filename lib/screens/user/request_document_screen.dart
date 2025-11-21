import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';

class RequestDocumentScreen extends StatefulWidget {
  const RequestDocumentScreen({super.key});

  @override
  State<RequestDocumentScreen> createState() => _RequestDocumentScreenState();
}

class _RequestDocumentScreenState extends State<RequestDocumentScreen> {
  // State variables
  final Set<String> _selectedDocuments = {};
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> _documentTypes = [
    'Barangay Clearance',
    'Certificate of Residency',
    'Certificate of Indigency',
    'Certificate of Good Moral Character',
    'Business Clearance',
    'Certificate of No Objection',
    'Certificate of Guardianship',
    'Certificate of Cohabitation',
    'Certificate of Appearance',
    'Certificate of Occupancy',
  ];

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)), // Allow requests up to 3 months in advance
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  Future<void> _submitRequest() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find user. Please log in again.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one document.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a requested date.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentData = {
        'userId': user.uid,
        'userName': user.fullName,
        'requestedDocuments': _selectedDocuments.toList(),
        'requestedDate': Timestamp.fromDate(_selectedDate!),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'rescheduledDate': null,
        'adminNotes': null,
      };

      await FirebaseFirestore.instance
          .collection('barangays')
          .doc(user.location.toDocumentId())
          .collection('appointments')
          .add(appointmentData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment request submitted successfully!'),
            backgroundColor: AppColors.brightBlue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: ${e.toString()}'), backgroundColor: Colors.red),
      );
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Request Barangay Document',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brightBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Documents',
              style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose one or more documents you would like to request.',
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ..._documentTypes.map((docType) {
              return CheckboxListTile(
                title: Text(docType, style: GoogleFonts.dmSans()),
                value: _selectedDocuments.contains(docType),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedDocuments.add(docType);
                    } else {
                      _selectedDocuments.remove(docType);
                    }
                  });
                },
                activeColor: AppColors.brightBlue,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const Divider(height: 32),
            Text(
              'Select Preferred Date',
              style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This is the date you wish to pick up the document(s).',
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _presentDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'No date chosen'
                          : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                      style: GoogleFonts.dmSans(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: AppColors.brightBlue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Submit Request',
                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
