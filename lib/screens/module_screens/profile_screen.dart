// lib/screens/profile_screen.dart (UPDATED WITH THEME COLORS)
import 'package:flutter/material.dart';
import 'package:roadfix/screens/profile_modules/app_info_modules.dart';
import 'package:roadfix/screens/profile_modules/edit_profile_screen.dart';
import 'package:roadfix/screens/profile_modules/change_email_screen.dart';
import 'package:roadfix/screens/profile_modules/change_password_screen.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/widgets/dialog_widgets/logout_confirmation_dialog.dart';
import 'package:roadfix/widgets/profile_widgets/profile_card.dart';
import 'package:roadfix/widgets/profile_widgets/status_summary_row.dart';
import 'package:roadfix/widgets/profile_widgets/profile_option_tile.dart';
import 'package:roadfix/widgets/profile_widgets/section_header.dart';
import 'package:roadfix/models/profile_option_model.dart';
import 'package:roadfix/models/profile_summary.dart';
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

  static void _noop() {}

  void _handleEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result == true && mounted) {
      setState(() {}); // Refresh the profile data
    }
  }

  void _handleChangeEmail() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangeEmailScreen()),
    );

    if (result == true && mounted) {
      setState(() {}); // Refresh the profile data if email was changed
    }
  }

  void _handleChangePassword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );

    if (result == true && mounted) {
      // Password change doesn't affect profile data, but we can show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: statusSuccess,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToAboutApp() {
    Navigator.push(context, AppInfoModuleScreen.route(AppInfoType.aboutApp));
  }

  void _navigateToTermsConditions() {
    Navigator.push(
      context,
      AppInfoModuleScreen.route(AppInfoType.termsConditions),
    );
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      AppInfoModuleScreen.route(AppInfoType.privacyPolicy),
    );
  }

  Future<void> _handleLogout() async {
    final bool? shouldLogout = await LogoutConfirmationDialog.show(context);

    if (shouldLogout == true && mounted) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        await _authService.signOut();

        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log out: ${e.toString()}'),
              backgroundColor: statusDanger,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

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
              child: StreamBuilder<ProfileSummary?>(
                stream: _userService.getCurrentUserProfileSummaryStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: statusDanger,
                          ),
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
                          SizedBox(height: 16),
                          // Note: ElevatedButton styling would need to be handled separately
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 64,
                            color: altSecondary,
                          ),
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

                  final profileSummary = snapshot.data!;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 2),

                        ProfileCard(
                          user: profileSummary,
                          summary: StatusSummaryRow(user: profileSummary),
                        ),
                        const SizedBox(height: 12),
                        const SectionHeader(title: 'Settings'),
                        const Divider(height: 1),

                        ProfileOptionTile(
                          option: ProfileOption(
                            icon: Icons.edit,
                            label: 'Edit Profile',
                            iconBackgroundColor:
                                primary, // Using existing primary color
                            onTap: _handleEditProfile,
                          ),
                        ),
                        const Divider(height: 1),

                        ProfileOptionTile(
                          option: ProfileOption(
                            icon: Icons.lock,
                            label: 'Enable Google Auth',
                            iconBackgroundColor:
                                redAccent, // Renamed theme color
                            onTap: _noop,
                          ),
                        ),
                        const Divider(height: 1),

                        ProfileOptionTile(
                          option: ProfileOption(
                            icon: Icons.email_outlined,
                            label: 'Change Email',
                            iconBackgroundColor:
                                greenAccent, // Renamed theme color
                            onTap: _handleChangeEmail,
                          ),
                        ),
                        const Divider(height: 1),

                        ProfileOptionTile(
                          option: ProfileOption(
                            icon: Icons.lock_outline,
                            label: 'Change Password',
                            iconBackgroundColor:
                                orangeAccent, // Renamed theme color
                            onTap: _handleChangePassword,
                          ),
                        ),
                        const Divider(height: 1),

                        const SectionHeader(title: 'App Info'),
                        const Divider(height: 1),

                        ProfileOptionTile(
                          option: ProfileOption(
                            icon: Icons.info_outline,
                            label: 'About App',
                            iconBackgroundColor:
                                purpleAccent, // Renamed theme color
                            onTap: _navigateToAboutApp,
                          ),
                        ),
                        const Divider(height: 1),

                        ProfileOptionTile(
                          option: ProfileOption(
                            icon: Icons.article_outlined,
                            label: 'Terms & Conditions',
                            iconBackgroundColor:
                                tealAccent, // Renamed theme color
                            onTap: _navigateToTermsConditions,
                          ),
                        ),
                        const Divider(height: 1),

                        ProfileOptionTile(
                          option: ProfileOption(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy Policy',
                            iconBackgroundColor:
                                indigoAccent, // Renamed theme color
                            onTap: _navigateToPrivacyPolicy,
                          ),
                        ),
                        const Divider(height: 1),

                        ProfileOptionTile(
                          option: ProfileOption(
                            icon: _isLoggingOut
                                ? Icons.hourglass_empty
                                : Icons.logout,
                            label: _isLoggingOut ? 'Logging out...' : 'Log Out',
                            iconBackgroundColor: redDark, // Renamed theme color
                            labelStyle: TextStyle(
                              color: _isLoggingOut
                                  ? altSecondary
                                  : statusDanger, // Using existing statusDanger
                            ),
                            onTap: _isLoggingOut
                                ? () {}
                                : () => _handleLogout(),
                          ),
                        ),
                        const Divider(height: 1),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
