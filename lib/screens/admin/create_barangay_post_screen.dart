import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class CreateBarangayPostScreen extends StatefulWidget {
  const CreateBarangayPostScreen({super.key});

  @override
  State<CreateBarangayPostScreen> createState() => _CreateBarangayPostScreenState();
}

class _CreateBarangayPostScreenState extends State<CreateBarangayPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPinned = false;
  bool _isCritical = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    final success = await postProvider.createPost(
      location: authProvider.currentUser!.location,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      authorId: authProvider.currentUser!.uid,
      authorName: authProvider.currentUser!.fullName,
      type: 'barangay',
      pinned: _isPinned,
      isCritical: _isCritical,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Barangay post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(postProvider.error ?? 'Failed to create post'),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Create Barangay Post',
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
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.brightBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: AppColors.brightBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Official barangay announcement - visible to all residents',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _titleController,
              label: 'Announcement Title',
              hint: 'Enter announcement title',
              textCapitalization: TextCapitalization.sentences,
              prefixIcon: Icon(Icons.campaign),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _contentController,
              label: 'Content',
              hint: 'Enter announcement details...',
              textCapitalization: TextCapitalization.sentences,
              maxLines: 8,
              prefixIcon: Icon(Icons.description),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Content is required';
                }
                if (value.trim().length < 10) {
                  return 'Content must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Pin Toggle
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text(
                  'Pin to Top',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Pinned posts appear at the top of the feed',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                value: _isPinned,
                onChanged: (value) => setState(() => _isPinned = value),
                activeColor: AppColors.brightBlue,
                secondary: Icon(Icons.push_pin, color: AppColors.brightBlue),
              ),
            ),

            const SizedBox(height: 12),

            // Critical Toggle
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text(
                  'Mark as Critical',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Critical advisories (e.g., flood warnings) show prominently',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                value: _isCritical,
                onChanged: (value) => setState(() => _isCritical = value),
                activeColor: AppColors.coralRed,
                secondary: Icon(Icons.warning_amber, color: AppColors.coralRed),
              ),
            ),

            const SizedBox(height: 32),
            CustomButton(
              text: 'Publish Announcement',
              onPressed: _createPost,
              isLoading: postProvider.isLoading,
              color: AppColors.brightBlue,
            ),
          ],
        ),
      ),
    );
  }
}