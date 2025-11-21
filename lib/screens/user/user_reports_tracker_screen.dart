// lib/screens/user/user_reports_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../models/report_model.dart';
import '../../models/appointment_model.dart'; // Import the appointment model
import '../../providers/auth_provider.dart';

// Enum to manage which tracker is active
enum TrackerType { reports, appointments }

class UserReportsTrackerScreen extends StatefulWidget {
  const UserReportsTrackerScreen({super.key});

  @override
  State<UserReportsTrackerScreen> createState() => _UserReportsTrackerScreenState();
}

class _UserReportsTrackerScreenState extends State<UserReportsTrackerScreen> {
  TrackerType _selectedTracker = TrackerType.reports;
  String _selectedStatusFilter = 'all';

  // Helper to format date
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Tracker')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Tracker', // More generic title
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
          // Segmented Control to switch between Reports and Appointments
          _buildTrackerSelector(),

          // Filter Chips for the selected tracker
          _buildFilterChips(),

          // The list view that changes based on the selected tracker
          Expanded(
            child: _selectedTracker == TrackerType.reports
                ? _buildReportsList(user.uid, user.location.toDocumentId())
                : _buildAppointmentsList(user.uid, user.location.toDocumentId()),
          ),
        ],
      ),
    );
  }

  /// Builds the top selector for 'Reports' or 'Appointments'
  Widget _buildTrackerSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<TrackerType>(
        segments: const [
          ButtonSegment(
            value: TrackerType.reports,
            label: Text('My Reports'),
            icon: Icon(Icons.report),
          ),
          ButtonSegment(
            value: TrackerType.appointments,
            label: Text('My Appointments'),
            icon: Icon(Icons.calendar_month),
          ),
        ],
        selected: {_selectedTracker},
        onSelectionChanged: (Set<TrackerType> newSelection) {
          setState(() {
            _selectedTracker = newSelection.first;
            _selectedStatusFilter = 'all'; // Reset filter when changing tracker type
          });
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.brightBlue.withOpacity(0.2),
          selectedForegroundColor: AppColors.brightBlue,
          foregroundColor: Colors.grey.shade600,
        ),
      ),
    );
  }

  /// Builds the horizontal list of filter chips
  Widget _buildFilterChips() {
    final reportStatuses = ['all', 'pending', 'in_progress', 'resolved', 'rejected'];
    final appointmentStatuses = ['all', 'pending', 'approved', 'rescheduled', 'rejected'];

    final statuses = _selectedTracker == TrackerType.reports ? reportStatuses : appointmentStatuses;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return _buildFilterChip(
            status[0].toUpperCase() + status.substring(1).replaceAll('_', ' '),
            status,
          );
        },
      ),
    );
  }

  /// A single filter chip widget
  Widget _buildFilterChip(String label, String statusValue) {
    final bool isSelected = _selectedStatusFilter == statusValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedStatusFilter = statusValue;
            });
          }
        },
        backgroundColor: Colors.grey.shade100,
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

  /// Builds the list of user reports
  Widget _buildReportsList(String userId, String barangayId) {
    final Stream<QuerySnapshot> reportsStream = FirebaseFirestore.instance
        .collection('barangays')
        .doc(barangayId)
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: reportsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brightBlue));
        }

        final allReports = snapshot.data!.docs.map((doc) => ReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final filteredReports = _selectedStatusFilter == 'all'
            ? allReports
            : allReports.where((report) => report.status == _selectedStatusFilter).toList();

        if (filteredReports.isEmpty) {
          return _buildEmptyState('Reports');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredReports.length,
          itemBuilder: (context, index) => _buildReportCard(filteredReports[index]),
        );
      },
    );
  }

  /// Builds the list of user appointments
  Widget _buildAppointmentsList(String userId, String barangayId) {
    final Stream<QuerySnapshot> appointmentsStream = FirebaseFirestore.instance
        .collection('barangays')
        .doc(barangayId)
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: appointmentsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brightBlue));
        }

        final allAppointments = snapshot.data!.docs.map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        allAppointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final filteredAppointments = _selectedStatusFilter == 'all'
            ? allAppointments
            : allAppointments.where((appt) => appt.status == _selectedStatusFilter).toList();

        if (filteredAppointments.isEmpty) {
          return _buildEmptyState('Appointments');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredAppointments.length,
          itemBuilder: (context, index) => _buildAppointmentCard(filteredAppointments[index]),
        );
      },
    );
  }

  /// A generic empty state widget
  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _selectedStatusFilter == 'all' ? 'No $type Found' : 'No $_selectedStatusFilter $type',
            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Your submitted $type will appear here.',
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Card widget for displaying a single Report
  Widget _buildReportCard(ReportModel report) {
    Color statusColor = _getReportStatusColor(report.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: InkWell(
        onTap: () => _showReportDetailsDialog(report),
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
                    child: Text(
                      report.title,
                      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoalBlack),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status.toUpperCase().replaceAll('_', ' '),
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                report.description,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.charcoalBlack.withOpacity(0.8), height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Submitted: ${_formatDate(report.createdAt)}',
                    style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card widget for displaying a single Appointment
  Widget _buildAppointmentCard(AppointmentModel appointment) {
    Color statusColor = _getAppointmentStatusColor(appointment.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetailsDialog(appointment),
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
                    child: Text(
                      'Document Request',
                      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoalBlack),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                'Requested Documents:',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              ...appointment.requestedDocuments.map((doc) => Text('• $doc', style: GoogleFonts.dmSans(height: 1.5))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Requested for: ${_formatDate(appointment.requestedDate)}',
                    style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const Spacer(),
                  if (appointment.status == 'rescheduled' && appointment.rescheduledDate != null)
                    Icon(Icons.event_repeat, size: 14, color: Colors.orange.shade700),
                  if (appointment.status == 'rescheduled' && appointment.rescheduledDate != null)
                    const SizedBox(width: 6),
                  if (appointment.status == 'rescheduled' && appointment.rescheduledDate != null)
                    Text(
                      'New Date: ${_formatDate(appointment.rescheduledDate!)}',
                      style: GoogleFonts.dmSans(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DIALOG TO SHOW FULL REPORT DETAILS
  void _showReportDetailsDialog(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(report.imageUrl!),
                  ),
                ),
              Text(report.description, style: GoogleFonts.dmSans(height: 1.5)),
              if (report.adminResponse != null && report.adminResponse!.isNotEmpty) ...[
                const Divider(height: 32),
                Text('Admin Response:', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.brightBlue)),
                const SizedBox(height: 8),
                Text(report.adminResponse!, style: GoogleFonts.dmSans(height: 1.5)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close', style: GoogleFonts.dmSans()),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // --- MODIFIED: DIALOG TO SHOW APPOINTMENT DETAILS (REMOVED RESCHEDULE ACTIONS) ---
  void _showAppointmentDetailsDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Details', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Documents:', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...appointment.requestedDocuments.map((doc) => Text('• $doc', style: GoogleFonts.dmSans(height: 1.5))),
              const Divider(height: 32),
              // Display Rescheduled Date if it exists
              if (appointment.status == 'rescheduled' && appointment.rescheduledDate != null) ...[
                Text('New Proposed Date:', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                const SizedBox(height: 8),
                Text(
                  _formatDate(appointment.rescheduledDate!),
                  style: GoogleFonts.dmSans(height: 1.5, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please contact the barangay office if you wish to accept or contest this new schedule.',
                  style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Divider(height: 32),
              ],
              // Display Admin Notes if they exist
              if (appointment.adminNotes != null && appointment.adminNotes!.isNotEmpty) ...[
                Text('Admin Notes:', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.brightBlue)),
                const SizedBox(height: 8),
                Text(appointment.adminNotes!, style: GoogleFonts.dmSans(height: 1.5)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close', style: GoogleFonts.dmSans()),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }


  // Status color helpers specific to each type
  Color _getReportStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.grey.shade600;
      case 'in_progress': return AppColors.goldenYellow;
      case 'resolved': return Colors.green;
      case 'rejected': return AppColors.coralRed;
      default: return Colors.black;
    }
  }

  Color _getAppointmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppColors.goldenYellow;
      case 'approved': return Colors.green;
      case 'rejected': return AppColors.coralRed;
      case 'rescheduled': return Colors.orange;
      default: return Colors.black;
    }
  }
}
