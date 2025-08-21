enum ReportCategoryType { pothole, utilityPole, roadConcern }

class ReportCategory {
  final String label;
  final String description;
  final String imagePath;
  final ReportCategoryType type;

  ReportCategory({
    required this.label,
    required this.description,
    required this.imagePath,
    required this.type,
  });
}
