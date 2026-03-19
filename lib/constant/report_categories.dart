import 'package:roadfix/models/report_category_model.dart';

final List<ReportCategory> reportCategories = [
  ReportCategory(
    label: 'Road Damage',
    description: 'Potholes and Road Cracks',
    imagePath: 'assets/images/pothole_report.webp',
    type: ReportCategoryType.pothole, // Keep same enum for compatibility
  ),
  ReportCategory(
    label: 'Utility Poles',
    description: 'Compromised or Broken Poles',
    imagePath: 'assets/images/utility_pole_report.webp',
    type: ReportCategoryType.utilityPole,
  ),
  ReportCategory(
    label: 'Road Blocks',
    description: 'Fallen Cones, Fallen Barriers, Tires',
    imagePath: 'assets/images/road_concerns.webp',
    type: ReportCategoryType.roadConcern,
  ),
];
