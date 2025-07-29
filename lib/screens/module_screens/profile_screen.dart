import 'package:flutter/material.dart';
import 'package:roadfix/widgets/header2.dart';
import 'package:roadfix/widgets/profile_widgets/profile_card.dart';
import 'package:roadfix/widgets/profile_widgets/status_summary_row.dart';
import 'package:roadfix/widgets/profile_widgets/profile_option_tile.dart';
import 'package:roadfix/widgets/profile_widgets/section_header.dart';
import 'package:roadfix/mock_datas/mock_profile.dart';
import 'package:roadfix/models/profile_option_model.dart';
import 'package:roadfix/widgets/themes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Column(
        children: [
          const Header2(title: 'Profile'),
          Expanded(
            child: Container(
              color: inputFill,
              // Removed horizontal padding here to make options full width
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 2,
                    ), // Very small gap between header and profile card
                    ProfileCard(
                      user: mockUser,
                      summary: StatusSummaryRow(user: mockUser),
                    ),
                    const SizedBox(height: 12),
                    const SectionHeader(title: 'Settings'),
                    const Divider(height: 1),

                    ProfileOptionTile(
                      option: ProfileOption(
                        icon: Icons.edit,
                        label: 'Edit Profile',
                        iconBackgroundColor: Colors.amber,
                        onTap: _noop,
                      ),
                    ),
                    const Divider(height: 1),

                    ProfileOptionTile(
                      option: ProfileOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        iconBackgroundColor: Colors.blueAccent,
                        onTap: _noop,
                      ),
                    ),
                    const Divider(height: 1),

                    ProfileOptionTile(
                      option: ProfileOption(
                        icon: Icons.lock,
                        label: 'Change Password',
                        iconBackgroundColor: Colors.redAccent,
                        onTap: _noop,
                      ),
                    ),
                    const Divider(height: 1),

                    ProfileOptionTile(
                      option: ProfileOption(
                        icon: Icons.language,
                        label: 'Language',
                        iconBackgroundColor: Colors.green,
                        onTap: _noop,
                      ),
                    ),
                    const Divider(height: 1),

                    const SectionHeader(title: 'App Info'),
                    const Divider(height: 1),

                    ProfileOptionTile(
                      option: ProfileOption(
                        icon: Icons.info_outline,
                        label: 'About App',
                        iconBackgroundColor: Colors.deepPurple,
                        onTap: _noop,
                      ),
                    ),
                    const Divider(height: 1),

                    ProfileOptionTile(
                      option: ProfileOption(
                        icon: Icons.article_outlined,
                        label: 'Terms & Conditions',
                        iconBackgroundColor: Colors.teal,
                        onTap: _noop,
                      ),
                    ),
                    const Divider(height: 1),

                    ProfileOptionTile(
                      option: ProfileOption(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        iconBackgroundColor: const Color.fromRGBO(
                          63,
                          81,
                          181,
                          1,
                        ),
                        onTap: _noop,
                      ),
                    ),
                    const Divider(height: 1),

                    ProfileOptionTile(
                      option: ProfileOption(
                        icon: Icons.logout,
                        label: 'Log Out',
                        iconBackgroundColor: const Color(0xFFF80101),
                        labelStyle: const TextStyle(color: Colors.red),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
