import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../services/storage_service.dart';
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
  final StorageService _storageService = StorageService();

  String? _imageUrl;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isUploadingImage = true);

    try {
      final imageUrl = await _storageService.pickAndUploadPostImage();

      if (imageUrl != null && mounted) {
        setState(() {
          _imageUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _removeImage() {
    setState(() => _imageUrl = null);
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
      imageUrl: _imageUrl,
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
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightYellow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldenYellow.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.image_outlined, color: AppColors.goldenYellow),
                  const SizedBox(width: 8),
                  Text(
                    'Add Image (Optional)',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_imageUrl != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.shade300,
                            child: Icon(Icons.error, size: 50, color: Colors.red),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.coralRed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _isUploadingImage ? null : _pickImage,
                  icon: _isUploadingImage
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldenYellow),
                          ),
                        )
                      : Icon(Icons.add_photo_alternate, color: AppColors.goldenYellow),
                  label: Text(
                    _isUploadingImage ? 'Uploading...' : 'Choose Image',
                    style: GoogleFonts.dmSans(color: AppColors.goldenYellow),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.goldenYellow),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
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