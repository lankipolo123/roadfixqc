// lib/screens/profile_screen.dart (UPDATED WITH TOTP FUNCTIONALITY)
import 'package:flutter/material.dart';
import 'package:roadfix/screens/profile_modules/app_info_modules.dart';
import 'package:roadfix/screens/profile_modules/edit_profile_screen.dart';
import 'package:roadfix/screens/profile_modules/change_email_screen.dart';
import 'package:roadfix/screens/profile_modules/change_password_screen.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/widgets/dialog_widgets/logout_confirmation_dialog.dart';
import 'package:roadfix/widgets/dialog_widgets/totp_setup_dialog.dart';
import 'package:roadfix/widgets/dialog_widgets/totp_disable_dialog.dart';
import 'package:roadfix/widgets/profile_widgets/profile_card.dart';
import 'package:roadfix/widgets/profile_widgets/status_summary_row.dart';
import 'package:roadfix/widgets/profile_widgets/profile_option_tile.dart';
import 'package:roadfix/widgets/profile_widgets/section_header.dart';
import 'package:roadfix/models/profile_option_model.dart';
import 'package:roadfix/models/profile_summary.dart';
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
    return Scaffold(
      backgroundColor: primary,
      body: Column(
        children: [
          const ModuleHeader(title: 'Profile', showBack: false),
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
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    if (snapshot.hasError) return _buildErrorState();
    if (!snapshot.hasData) return _buildNoDataState();

    final user = snapshot.data!;
    final profileSummary = _userService.userToProfileSummary(user);

    return _buildProfileContent(profileSummary, user);
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: statusDanger),
          SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: altSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(fontSize: 14, color: altSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: altSecondary),
          SizedBox(height: 16),
          Text(
            'No profile data found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: altSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(ProfileSummary profileSummary, UserModel user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 2),
          ProfileCard(
            user: profileSummary,
            summary: StatusSummaryRow(user: profileSummary),
          ),
          const SizedBox(height: 12),
          _buildSettingsSection(user),
          _buildAppInfoSection(),
          _buildHowToUseTile(),
          _buildLogoutTile(),
          const SizedBox(height: 24),
        ],
      ),
    );
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
        _buildTotpOptionTile(user),
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

  Widget _buildTotpOptionTile(UserModel user) {
    return Column(
      children: [
        const Divider(height: 1),
        ProfileOptionTile(
          option: ProfileOption(
            icon: user.totpEnabled ? Icons.verified_user : Icons.security,
            label: user.totpEnabled ? 'Disable 2FA' : 'Enable 2FA',
            iconBackgroundColor: user.totpEnabled ? statusSuccess : redAccent,
            trailing: user.totpEnabled
                ? const Icon(Icons.check_circle, color: statusSuccess, size: 16)
                : null,
            onTap: () => _handleTotpToggle(user),
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
            onTap: () {}, // placeholder
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

  // Navigation handlers
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

  Future<void> _handleTotpToggle(UserModel user) async {
    try {
      bool? result;

      if (user.totpEnabled) {
        // Show disable dialog
        result = await TotpDisableDialog.show(context);

        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Two-Factor Authentication disabled'),
              backgroundColor: statusWarning,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Show setup dialog
        result = await TotpSetupDialog.show(context);

        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Two-Factor Authentication enabled successfully'),
              backgroundColor: statusSuccess,
              duration: Duration(seconds: 3),
            ),
          );
        }
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
