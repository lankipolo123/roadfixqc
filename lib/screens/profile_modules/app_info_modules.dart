import 'package:flutter/material.dart';
import 'package:roadfix/constant/profile_module_constant.dart';
import 'package:roadfix/widgets/common_widgets/diagonal_stripes.dart';
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
      // Remove backgroundColor property to use custom background
      // Floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: secondary,
        foregroundColor: primary,
        elevation: 4,
        icon: const Icon(Icons.arrow_back),
        label: const Text(
          'Back to Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          // Full-page diagonal stripes background
          Positioned.fill(
            child: DiagonalStripes(height: MediaQuery.of(context).size.height),
          ),
          // Main content
          Column(
            children: [
              // Header without title (clean look)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content card with primary background
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with icon - inline
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getIconForType(),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      data['title']!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Divider
                              Container(
                                height: 1,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                              ),

                              const SizedBox(height: 24),

                              // Content with proper formatting
                              Text(
                                data['content']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.7,
                                  color: secondary,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              // Footer for About App
                              if (infoType == AppInfoType.aboutApp) ...[
                                const SizedBox(height: 32),

                                // App Information Section
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        primary.withValues(alpha: 0.1),
                                        primary.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primary.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.info,
                                            color: primary,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'App Information',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
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

                      // Extra space for floating button
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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

  // Helper method to build info rows for About App - Simple
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
