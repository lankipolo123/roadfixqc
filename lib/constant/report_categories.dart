import 'package:roadfix/models/report_category_model.dart';

final List<ReportCategory> reportCategories = [
  ReportCategory(
    label: 'Road Damage',
    description: 'Potholes',
    imagePath: 'assets/images/pothole_report.webp',
    type: ReportCategoryType.pothole,
  ),
  ReportCategory(
    label: 'Utility Poles',
    description: 'Fallen Poles',
    imagePath: 'assets/images/utility_pole_report.webp',
    type: ReportCategoryType.utilityPole,
  ),
  ReportCategory(
    label: 'Road Blocks',
    description: 'Fallen Cones, Fallen Barriers',
    imagePath: 'assets/images/road_concerns.webp',
    type: ReportCategoryType.roadConcern,
  ),
];
