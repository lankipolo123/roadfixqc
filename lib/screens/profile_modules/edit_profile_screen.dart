// lib/screens/profile_modules/edit_profile_screen.dart (FIXED - UPLOAD ON SAVE)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/services/imagekit_services.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/widgets/common_widgets/custom_text_field.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/widgets/dialog_widgets/image_source_dialog.dart';
import 'package:roadfix/widgets/themes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _imageKitService = ImageKitService();
  final _imagePicker = ImagePicker();

  // Controllers
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();

  // State variables
  bool _isLoading = true;
  bool _isSaving = false;
  String? _originalProfileImageUrl; // Store original URL from database
  File? _selectedImageFile; // Store selected image file (not uploaded yet)
  bool _hasImageChanged = false; // Track if image was changed

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _contactNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    try {
      final user = await _userService.getCurrentUser();

      if (user != null && mounted) {
        setState(() {
          _contactNumberController.text = user.contactNumber;
          _addressController.text = user.address;
          _originalProfileImageUrl = user.userProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load profile: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: statusDanger,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: statusSuccess,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Pick image and show local preview (NO UPLOAD YET)
  Future<void> _pickImage() async {
    if (!mounted) return;

    try {
      final source = await ImageSourceDialog.show(context);
      if (source == null || !mounted) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _hasImageChanged = true;
        });

        _showSuccessSnackBar(
          'Image selected! Tap Save to upload and confirm changes.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to select image: $e');
      }
    }
  }

  /// Get the image to display (local file or network URL)
  ImageProvider? _getImageProvider() {
    if (_selectedImageFile != null) {
      return FileImage(_selectedImageFile!); // Show local preview
    } else if (_originalProfileImageUrl != null &&
        _originalProfileImageUrl!.isNotEmpty) {
      return NetworkImage(
        _originalProfileImageUrl!,
      ); // Show current from database
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!mounted || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? finalImageUrl = _originalProfileImageUrl; // Default to original

      // Upload new image if one was selected
      if (_hasImageChanged && _selectedImageFile != null) {
        final response = await _imageKitService.uploadProfileImage(
          _selectedImageFile!,
        );
        finalImageUrl = response.fileUrl;
      }

      // Update profile with all data
      await _userService.updateProfile(
        contactNumber: _contactNumberController.text.trim(),
        address: _addressController.text.trim(),
        imageUrl: finalImageUrl,
      );

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully!');
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Column(
        children: [
          const ModuleHeader(title: 'Edit Profile', showBack: true),
          Expanded(
            child: Container(
              color: inputFill,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primary),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile Image Section
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primary.withValues(alpha: 0.2),
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _getImageProvider(),
                                      child: _getImageProvider() == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: secondary,
                                            )
                                          : null,
                                    ),
                                  ),

                                  // Change indicator for selected image
                                  if (_hasImageChanged)
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: statusSuccess,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),

                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: secondary.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: inputFill,
                                          size: 20,
                                        ),
                                        onPressed: _isSaving
                                            ? null
                                            : _pickImage,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              _hasImageChanged
                                  ? 'New image selected! Tap Save to upload.'
                                  : 'Tap the camera icon to change your profile picture',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: _hasImageChanged
                                    ? statusSuccess
                                    : altSecondary,
                                fontWeight: _hasImageChanged
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),

                            const SizedBox(height: 32),

                            PhoneTextField(
                              controller: _contactNumberController,
                              label: 'Contact Number',
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: _addressController,
                              label: 'Address',
                              hintText: 'Enter your complete address',
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Address is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: inputFill,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: inputFill,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _hasImageChanged
                                            ? 'Save & Upload Image'
                                            : 'Save Changes',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () {
                                        if (mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primary,
                                  side: const BorderSide(color: primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
