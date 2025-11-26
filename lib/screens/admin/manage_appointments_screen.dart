// lib/screens/admin/manage_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  State<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  String _selectedFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final barangayId = authProvider.currentUser?.location.toDocumentId() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Document Requests',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brightBlue),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Pending', 'pending'),
                  _buildFilterChip('Approved', 'approved'),
                  _buildFilterChip('Rescheduled', 'rescheduled'),
                  _buildFilterChip('Rejected', 'rejected'),
                  _buildFilterChip('All', 'all'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getAppointmentsStream(barangayId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: GoogleFonts.dmSans(color: AppColors.coralRed)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.brightBlue));
                }
                var appointments = (snapshot.data?.docs ?? [])
                    .map((doc) =>
                    AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();
                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off_outlined,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No ${_selectedFilter} requests found',
                            style: GoogleFonts.dmSans(
                                fontSize: 18, color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(appointments[index], barangayId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getAppointmentsStream(String barangayId) {
    Query query = FirebaseFirestore.instance
        .collection('barangays')
        .doc(barangayId)
        .collection('appointments');

    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: AppColors.white,
        selectedColor: AppColors.brightBlue.withOpacity(0.2),
        checkmarkColor: AppColors.brightBlue,
        labelStyle: GoogleFonts.dmSans(
          color: isSelected ? AppColors.brightBlue : AppColors.charcoalBlack,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.brightBlue : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, String barangayId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: _getStatusColor(appointment.status).withOpacity(0.4), width: 1.5),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetailsDialog(appointment, barangayId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appointment.userName,
                            style: GoogleFonts.dmSans(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            'Requested: ${_formatDate(appointment.requestedDate)}',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(appointment.status)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text('Documents:',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              ...appointment.requestedDocuments
                  .map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('• $doc',
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.charcoalBlack.withOpacity(0.8))),
              ))
                  .toList(),
              if (appointment.status == 'rescheduled' && appointment.rescheduledDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.orange.shade700, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Rescheduled to: ${_formatDate(appointment.rescheduledDate!)}',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetailsDialog(AppointmentModel appointment, String barangayId) {
    String selectedStatus = appointment.status;
    DateTime? newRescheduledDate = appointment.rescheduledDate;
    final notesController = TextEditingController(text: appointment.adminNotes ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Request Details',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Text('Update Status:', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['pending', 'approved', 'rescheduled', 'rejected']
                        .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status[0].toUpperCase() + status.substring(1))))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedStatus = value);
                      }
                    },
                  ),
                  if (selectedStatus == 'rescheduled') ...[
                    const SizedBox(height: 16),
                    Text('New Appointment Date:', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: newRescheduledDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (pickedDate != null) {
                          setState(() => newRescheduledDate = pickedDate);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(newRescheduledDate == null
                                ? 'Select new date'
                                : _formatDate(newRescheduledDate!)),
                            const Icon(Icons.calendar_today, color: AppColors.brightBlue),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('Admin Notes (Optional):', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Reason for rejection/reschedule...'),
                    maxLines: 2,
                  ),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                  if (selectedStatus == 'rescheduled' && newRescheduledDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please select a new date for rescheduling.'),
                        backgroundColor: AppColors.coralRed));
                    return;
                  }

                  final updates = {
                    'status': selectedStatus,
                    'adminNotes': notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    'rescheduledDate': selectedStatus == 'rescheduled' ? Timestamp.fromDate(newRescheduledDate!) : null,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };

                  await FirebaseFirestore.instance
                      .collection('barangays')
                      .doc(barangayId)
                      .collection('appointments')
                      .doc(appointment.id)
                      .update(updates);

                  if (selectedStatus != appointment.status) {
                    await _sendNotification(
                      barangayId: barangayId,
                      userId: appointment.userId,
                      appointmentId: appointment.id, // Pass the ID
                      status: selectedStatus,
                    );
                  }

                            if (mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brightBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Update', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- UPDATED: FUNCTION TO SEND NOTIFICATION ---
  Future<void> _sendNotification({
    required String barangayId,
    required String userId,
    required String appointmentId,
    required String status,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'approved':
        title = 'Document Request Approved';
        body = 'Your request for documents has been approved. You can check the tracker for your QR code to claim them.';
        break;
      case 'rejected':
        title = 'Document Request Rejected';
        body = 'Your recent document request has been rejected. Please check the app for notes from the admin.';
        break;
      case 'rescheduled':
        title = 'Document Request Rescheduled';
        body = 'Your document request has been rescheduled. Please check the tracker for the new proposed date.';
        break;
      default:
        return;
    }

    final notificationData = {
      'userId': userId,
      'title': title,
      'body': body,
      'type': 'appointment_update',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
      'appointmentId': appointmentId, // Include the appointment ID
    };

    await FirebaseFirestore.instance
        .collection('barangays')
        .doc(barangayId)
        .collection('notifications')
        .add(notificationData);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.goldenYellow;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return AppColors.coralRed;
      case 'rescheduled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
