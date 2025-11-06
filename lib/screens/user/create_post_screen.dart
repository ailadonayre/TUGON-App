import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

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
      type: 'community',
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Post created successfully!'),
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
            'Create Post',
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
                  'Your post will be visible to all residents in your barangay',
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
          label: 'Post Title',
          hint: 'Enter a clear title',
          textCapitalization: TextCapitalization.sentences,
          prefixIcon: Icon(Icons.title),
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
          hint: 'Share your thoughts with the community...',
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
        const SizedBox(height: 32),
                CustomButton(
                  text: 'Post to Community',
                  onPressed: _createPost,
                  isLoading: postProvider.isLoading,
                ),
              ],
          ),
        ),
    );
  }
}