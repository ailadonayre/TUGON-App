import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/hotline_model.dart';
import '../../providers/auth_provider.dart';

class ManageHotlinesScreen extends StatefulWidget {
  const ManageHotlinesScreen({super.key});

  @override
  State<ManageHotlinesScreen> createState() => _ManageHotlinesScreenState();
}

class _ManageHotlinesScreenState extends State<ManageHotlinesScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final barangayId = authProvider.currentUser?.location.toDocumentId() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Hotlines',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brightBlue),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHotlineDialog(barangayId),
        backgroundColor: AppColors.brightBlue,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text(
          'Add Hotline',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('barangays')
            .doc(barangayId)
            .collection('hotlines')
            .orderBy('displayOrder')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.dmSans(color: AppColors.coralRed),
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

          final hotlines = snapshot.data?.docs ?? [];

          if (hotlines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hotlines added yet',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a hotline',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: hotlines.length,
            itemBuilder: (context, index) {
              final hotline = HotlineModel.fromMap(
                hotlines[index].data() as Map<String, dynamic>,
                hotlines[index].id,
              );
              return _buildHotlineCard(hotline, barangayId);
            },
          );
        },
      ),
    );
  }

  Widget _buildHotlineCard(HotlineModel hotline, String barangayId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hotline.isEmergency ? AppColors.coralRed : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(hotline.category).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(hotline.category),
                    color: _getCategoryColor(hotline.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
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
                          if (hotline.isEmergency)
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
                                'EMERGENCY',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: AppColors.brightBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hotline.phoneNumber,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brightBlue,
                            ),
                          ),
                        ],
                      ),
                      if (hotline.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          hotline.description!,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) =>
                      _handleHotlineAction(value, hotline, barangayId),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            hotline.isActive
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(hotline.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.coralRed),
                          SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.coralRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(hotline.category).withValues(alpha: 0.2),
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hotline.isActive
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    hotline.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: hotline.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  void _handleHotlineAction(
      String action, HotlineModel hotline, String barangayId) async {
    final docRef = FirebaseFirestore.instance
        .collection('barangays')
        .doc(barangayId)
        .collection('hotlines')
        .doc(hotline.id);

    try {
      switch (action) {
        case 'edit':
          _showEditHotlineDialog(hotline, barangayId);
          break;

        case 'toggle':
          await docRef.update({
            'isActive': !hotline.isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  hotline.isActive ? 'Hotline deactivated' : 'Hotline activated',
                ),
                backgroundColor: AppColors.brightBlue,
              ),
            );
          }
          break;

        case 'delete':
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Delete Hotline',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete this hotline?',
                style: GoogleFonts.dmSans(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.dmSans(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.dmSans(color: AppColors.coralRed),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await docRef.delete();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hotline deleted'),
                  backgroundColor: AppColors.coralRed,
                ),
              );
            }
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    }
  }

  void _showAddHotlineDialog(String barangayId) {
    _showHotlineDialog(barangayId);
  }

  void _showEditHotlineDialog(HotlineModel hotline, String barangayId) {
    _showHotlineDialog(barangayId, hotline: hotline);
  }

  void _showHotlineDialog(String barangayId, {HotlineModel? hotline}) {
    final nameController = TextEditingController(text: hotline?.name ?? '');
    final phoneController = TextEditingController(text: hotline?.phoneNumber ?? '');
    final descController = TextEditingController(text: hotline?.description ?? '');
    String selectedCategory = hotline?.category ?? 'emergency';
    bool isEmergency = hotline?.isEmergency ?? false;
    bool isActive = hotline?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            hotline == null ? 'Add Hotline' : 'Edit Hotline',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\+\(\)\s]')),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'emergency', child: Text('Emergency')),
                    DropdownMenuItem(value: 'health', child: Text('Health')),
                    DropdownMenuItem(value: 'police', child: Text('Police')),
                    DropdownMenuItem(value: 'fire', child: Text('Fire')),
                    DropdownMenuItem(
                        value: 'barangay', child: Text('Barangay')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: Text(
                    'Mark as Emergency',
                    style: GoogleFonts.dmSans(fontSize: 14),
                  ),
                  value: isEmergency,
                  onChanged: (value) {
                    setState(() => isEmergency = value ?? false);
                  },
                  activeColor: AppColors.coralRed,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Text(
                    'Active',
                    style: GoogleFonts.dmSans(fontSize: 14),
                  ),
                  value: isActive,
                  onChanged: (value) {
                    setState(() => isActive = value ?? true);
                  },
                  activeColor: AppColors.brightBlue,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: AppColors.coralRed,
                    ),
                  );
                  return;
                }

                try {
                  final data = {
                    'name': nameController.text,
                    'phoneNumber': phoneController.text,
                    'description': descController.text.isEmpty
                        ? null
                        : descController.text,
                    'category': selectedCategory,
                    'barangayId': barangayId,
                    'isActive': isActive,
                    'isEmergency': isEmergency,
                    'displayOrder': 0,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };

                  if (hotline == null) {
                    data['createdAt'] = FieldValue.serverTimestamp();
                    await FirebaseFirestore.instance
                        .collection('barangays')
                        .doc(barangayId)
                        .collection('hotlines')
                        .add(data);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('barangays')
                        .doc(barangayId)
                        .collection('hotlines')
                        .doc(hotline.id)
                        .update(data);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          hotline == null
                              ? 'Hotline added successfully'
                              : 'Hotline updated successfully',
                        ),
                        backgroundColor: AppColors.brightBlue,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppColors.coralRed,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightBlue,
                foregroundColor: AppColors.white,
              ),
              child: Text(
                hotline == null ? 'Add' : 'Update',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
