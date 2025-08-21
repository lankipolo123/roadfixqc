import 'package:flutter/material.dart';
import 'package:roadfix/constant/profile_module_constant.dart';
import 'package:roadfix/layouts/striped_form_layout.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/widgets/themes.dart';

enum AppInfoType { aboutApp, termsConditions, privacyPolicy }

class AppInfoModuleScreen extends StatelessWidget {
  final AppInfoType infoType;

  const AppInfoModuleScreen({super.key, required this.infoType});

  // Static method to create routes
  static Route<void> route(AppInfoType type) {
    return MaterialPageRoute(
      builder: (context) => AppInfoModuleScreen(infoType: type),
    );
  }

  // Get content based on type
  Map<String, String> get contentData {
    switch (infoType) {
      case AppInfoType.aboutApp:
        return ProfileModuleConstants.aboutApp;
      case AppInfoType.termsConditions:
        return ProfileModuleConstants.termsConditions;
      case AppInfoType.privacyPolicy:
        return ProfileModuleConstants.privacyPolicy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = contentData;

    return Scaffold(
      backgroundColor: primary,
      body: StripedFormLayout(
        child: Column(
          children: [
            ModuleHeader(title: data['title']!, showBack: true),
            Expanded(
              child: Container(
                color: inputFill,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content card with elevated design
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primary.withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getIconForType(),
                                      color: primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      data['title']!,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Content with proper formatting
                              Text(
                                data['content']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: secondary,
                                ),
                              ),

                              // Footer for About App
                              if (infoType == AppInfoType.aboutApp) ...[
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primary.withAlpha(13),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: primary.withAlpha(51),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'App Information',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        'Version',
                                        ProfileModuleConstants.appVersion,
                                      ),
                                      _buildInfoRow(
                                        'Developed by',
                                        ProfileModuleConstants.developedBy,
                                      ),
                                      _buildInfoRow(
                                        'Institution',
                                        ProfileModuleConstants.institution,
                                      ),
                                      _buildInfoRow(
                                        'Project Type',
                                        ProfileModuleConstants.projectType,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        ProfileModuleConstants.copyright,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: altSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Back button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: inputFill,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Back to Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get appropriate icon
  IconData _getIconForType() {
    switch (infoType) {
      case AppInfoType.aboutApp:
        return Icons.info_outline;
      case AppInfoType.termsConditions:
        return Icons.article_outlined;
      case AppInfoType.privacyPolicy:
        return Icons.privacy_tip_outlined;
    }
  }

  // Helper method to build info rows for About App
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: altSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: secondary),
            ),
          ),
        ],
      ),
    );
  }
}
