import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../models/hotline_model.dart';
import '../../providers/auth_provider.dart';

class UserHotlinesScreen extends StatelessWidget {
  const UserHotlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final barangayId = authProvider.currentUser?.location.toDocumentId() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Hotlines',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brightBlue),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('barangays')
            .doc(barangayId)
            .collection('hotlines')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.coralRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading hotlines',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: AppColors.coralRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.brightBlue,
              ),
            );
          }

          var hotlines = (snapshot.data?.docs ?? []).map((doc) {
            return HotlineModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          // Sort client-side: emergency first, then by displayOrder, then by createdAt
          hotlines.sort((a, b) {
            if (a.isEmergency != b.isEmergency) {
              return a.isEmergency ? -1 : 1;
            }
            final orderCompare = a.displayOrder.compareTo(b.displayOrder);
            if (orderCompare != 0) return orderCompare;
            return b.createdAt.compareTo(a.createdAt);
          });

          if (hotlines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_disabled,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hotlines available',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for emergency contacts',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final emergencyHotlines = hotlines.where((h) => h.isEmergency).toList();
          final regularHotlines = hotlines.where((h) => !h.isEmergency).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Emergency Banner
              if (emergencyHotlines.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightRed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.coralRed, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emergency,
                        color: AppColors.coralRed,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EMERGENCY CONTACTS',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.coralRed,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to call immediately',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.charcoalBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Emergency Hotlines
                ...emergencyHotlines.map((hotline) {
                  return _buildHotlineCard(context, hotline, isEmergency: true);
                }),

                const SizedBox(height: 32),

                // Regular Hotlines Header
                Text(
                  'Other Contacts',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Regular Hotlines
              ...regularHotlines.map((hotline) {
                return _buildHotlineCard(context, hotline);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHotlineCard(BuildContext context, HotlineModel hotline,
      {bool isEmergency = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isEmergency ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEmergency
              ? AppColors.coralRed
              : _getCategoryColor(hotline.category).withValues(alpha: 0.3),
          width: isEmergency ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _makePhoneCall(hotline.phoneNumber),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getCategoryColor(hotline.category).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(hotline.category),
                  color: _getCategoryColor(hotline.category),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hotline.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoalBlack,
                            ),
                          ),
                        ),
                        if (isEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.coralRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SOS',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 18,
                          color: AppColors.brightBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hotline.phoneNumber,
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brightBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _copyToClipboard(
                              context, hotline.phoneNumber),
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (hotline.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        hotline.description!,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(hotline.category)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        hotline.category.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(hotline.category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Call Button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEmergency
                      ? AppColors.coralRed
                      : AppColors.brightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'emergency':
        return AppColors.coralRed;
      case 'health':
        return Colors.green;
      case 'police':
        return Colors.blue;
      case 'fire':
        return Colors.orange;
      case 'barangay':
        return AppColors.brightBlue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'emergency':
        return Icons.emergency;
      case 'health':
        return Icons.local_hospital;
      case 'police':
        return Icons.local_police;
      case 'fire':
        return Icons.local_fire_department;
      case 'barangay':
        return Icons.location_city;
      default:
        return Icons.phone;
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Phone number copied to clipboard',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: AppColors.brightBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
