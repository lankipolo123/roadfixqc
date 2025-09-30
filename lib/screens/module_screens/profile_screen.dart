// lib/screens/profile_screen.dart (Complete Implementation)
import 'package:flutter/material.dart';
import 'package:roadfix/screens/profile_modules/app_info_modules.dart';
import 'package:roadfix/screens/profile_modules/edit_profile_screen.dart';
import 'package:roadfix/screens/profile_modules/change_email_screen.dart';
import 'package:roadfix/screens/profile_modules/change_password_screen.dart';
import 'package:roadfix/screens/tutorial_screens/step_one_screen.dart';
import 'package:roadfix/widgets/dialog_widgets/logout_confirmation_dialog.dart';
import 'package:roadfix/widgets/dialog_widgets/totp_setup_dialog.dart';
import 'package:roadfix/widgets/dialog_widgets/totp_disable_dialog.dart';
import 'package:roadfix/widgets/profile_widgets/profile_card.dart';
import 'package:roadfix/widgets/profile_widgets/status_summary_row.dart';
import 'package:roadfix/widgets/profile_widgets/profile_option_tile.dart';
import 'package:roadfix/widgets/profile_widgets/section_header.dart';
import 'package:roadfix/layouts/profile_screen_layout.dart';
import 'package:roadfix/models/profile_option_model.dart';
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/widgets/themes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return ProfileScreenLayout(
      title: 'Profile',
      contentBuilder: (context) {
        return StreamBuilder<UserModel?>(
          stream: _userService.getCurrentUserStream(),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ProfileScreenLayout.buildLoadingState();
            }

            // Error state
            if (snapshot.hasError) {
              return ProfileScreenLayout.buildErrorState();
            }

            // No data state
            if (!snapshot.hasData) {
              return ProfileScreenLayout.buildNoDataState();
            }

            // Success state - build profile content
            return ProfileScreenLayout.buildScrollableContent(
              children: _buildProfileContent(snapshot.data!),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildProfileContent(UserModel user) {
    return [
      const SizedBox(height: 2),
      ProfileCard(user: user),
      const SizedBox(height: 12),
      const StatusSummaryRow(),
      const SizedBox(height: 12),
      _buildSettingsSection(user),
      _buildAppInfoSection(),
      _buildHowToUseTile(),
      _buildLogoutTile(),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildSettingsSection(UserModel user) {
    return Column(
      children: [
        const SectionHeader(title: 'Settings'),
        _buildOptionTile(
          Icons.edit,
          'Edit Profile',
          primary,
          _handleEditProfile,
        ),
        _buildTotpOptionTile(user), // This now has the switch!
        _buildOptionTile(
          Icons.email_outlined,
          'Change Email',
          greenAccent,
          _handleChangeEmail,
        ),
        _buildOptionTile(
          Icons.lock_outline,
          'Change Password',
          orangeAccent,
          _handleChangePassword,
        ),
      ],
    );
  }

  // Updated TOTP option tile with switch
  Widget _buildTotpOptionTile(UserModel user) {
    return Column(
      children: [
        const Divider(height: 1),
        ProfileOptionTile(
          option: ProfileOption(
            icon: user.totpEnabled ? Icons.verified_user : Icons.security,
            label: 'Two-Factor Authentication',
            iconBackgroundColor: user.totpEnabled ? statusSuccess : redAccent,
            mode: ProfileOptionMode.toggle,
            toggleValue: user.totpEnabled,
            onToggleChanged: (value) async {
              // Handle the toggle change
              await _handleTotpToggle(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return Column(
      children: [
        const SectionHeader(title: 'App Info'),
        _buildOptionTile(
          Icons.info_outline,
          'About App',
          purpleAccent,
          () => Navigator.push(
            context,
            AppInfoModuleScreen.route(AppInfoType.aboutApp),
          ),
        ),
        _buildOptionTile(
          Icons.article_outlined,
          'Terms & Conditions',
          tealAccent,
          () => Navigator.push(
            context,
            AppInfoModuleScreen.route(AppInfoType.termsConditions),
          ),
        ),
        _buildOptionTile(
          Icons.privacy_tip_outlined,
          'Privacy Policy',
          indigoAccent,
          () => Navigator.push(
            context,
            AppInfoModuleScreen.route(AppInfoType.privacyPolicy),
          ),
        ),
      ],
    );
  }

  Widget _buildHowToUseTile() {
    return Column(
      children: [
        const Divider(height: 1),
        ProfileOptionTile(
          option: ProfileOption(
            icon: Icons.help_outline,
            label: 'How to Use',
            iconBackgroundColor: Colors.blueAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TutorialStep1Screen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        const Divider(height: 1),
        ProfileOptionTile(
          option: ProfileOption(
            icon: icon,
            label: label,
            iconBackgroundColor: color,
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutTile() {
    return Column(
      children: [
        const Divider(height: 1),
        ProfileOptionTile(
          option: ProfileOption(
            icon: _isLoggingOut ? Icons.hourglass_empty : Icons.logout,
            label: _isLoggingOut ? 'Logging out...' : 'Log Out',
            iconBackgroundColor: redDark,
            labelStyle: TextStyle(
              color: _isLoggingOut ? altSecondary : statusDanger,
            ),
            onTap: _isLoggingOut ? () {} : _handleLogout,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  // Event handlers
  void _handleEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (result == true && mounted) setState(() {});
  }

  void _handleChangeEmail() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangeEmailScreen()),
    );
    if (result == true && mounted) setState(() {});
  }

  void _handleChangePassword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: statusSuccess,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Updated TOTP handler to work better with switch
  Future<void> _handleTotpToggle(UserModel user) async {
    try {
      bool? result;

      if (user.totpEnabled) {
        // Disable 2FA
        result = await TotpDisableDialog.show(context);
      } else {
        // Enable 2FA
        result = await TotpSetupDialog.show(context);
      }

      if (result == true && mounted) {
        // The UI will automatically update via the StreamBuilder
        // when the user data changes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.totpEnabled
                  ? 'Two-Factor Authentication disabled'
                  : 'Two-Factor Authentication enabled successfully',
            ),
            backgroundColor: user.totpEnabled ? statusWarning : statusSuccess,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update 2FA settings: $e'),
            backgroundColor: statusDanger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await LogoutConfirmationDialog.show(context);
    if (shouldLogout != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log out: $e'),
            backgroundColor: statusDanger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
