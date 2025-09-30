// lib/screens/profile_modules/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/services/imagekit_services.dart';
import 'package:roadfix/widgets/common_widgets/custom_text_field.dart';
import 'package:roadfix/widgets/common_widgets/user_avatar.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/models/user_model.dart';
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
  bool _isSaving = false;
  File? _selectedImageFile;
  bool _hasImageChanged = false;

  @override
  void dispose() {
    _contactNumberController.dispose();
    _addressController.dispose();
    super.dispose();
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
      if (mounted) _showErrorSnackBar('Failed to select image: $e');
    }
  }

  Future<void> _saveProfile(UserModel user) async {
    if (!mounted || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String? finalImageUrl = user.userProfile;

      // Upload new image if selected
      if (_hasImageChanged && _selectedImageFile != null) {
        final response = await _imageKitService.uploadProfileImage(
          _selectedImageFile!,
        );
        final rawUrl = (response.fileUrl).trim();
        finalImageUrl = rawUrl
            .split('?')
            .first; // Clean URL without query params
      }

      final lastUpdated = DateTime.now().millisecondsSinceEpoch;

      await _userService.updateProfile(
        contactNumber: _contactNumberController.text.trim(),
        address: _addressController.text.trim(),
        userProfile: finalImageUrl,
        lastUpdated: lastUpdated,
      );

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: inputFill,
              child: StreamBuilder<UserModel?>(
                stream: _userService.getCurrentUserStream(),
                builder: (context, snapshot) => _buildBody(snapshot),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<UserModel?> snapshot) {
    // Handle loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    // Handle error state
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: statusDanger),
            const SizedBox(height: 16),
            const Text(
              'Failed to load profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: altSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    // Handle no user data
    if (!snapshot.hasData) {
      return const Center(
        child: Text(
          'No user data found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: altSecondary,
          ),
        ),
      );
    }

    final user = snapshot.data!;

    // Initialize controllers with user data if they're empty
    if (_contactNumberController.text.isEmpty) {
      _contactNumberController.text = user.contactNumber;
    }
    if (_addressController.text.isEmpty) {
      _addressController.text = user.address;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        30,
        80,
        30,
        30,
      ), // Added 80px top padding
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
                        color: primary.withValues(alpha: 51),
                        width: 3,
                      ),
                    ),
                    child: _selectedImageFile != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(_selectedImageFile!),
                          )
                        : UserAvatar(
                            imageUrl: user.userProfile,
                            radius: 60,
                            lastUpdated: user.lastUpdated,
                          ),
                  ),
                  if (_hasImageChanged)
                    Positioned(
                      top: 30,
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
                            color: secondary.withValues(alpha: 51),
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
                        onPressed: _isSaving ? null : _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
            Text(
              _hasImageChanged
                  ? 'New image selected! Tap Save to upload.'
                  : 'Tap the camera icon to change your profile picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _hasImageChanged ? statusSuccess : altSecondary,
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
                onPressed: _isSaving ? null : () => _saveProfile(user),
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
                        child: CircularProgressIndicator(color: inputFill),
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
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
