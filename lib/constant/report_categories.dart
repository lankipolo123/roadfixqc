import 'package:roadfix/models/report_category_model.dart';

final List<ReportCategory> reportCategories = [
  ReportCategory(
    label: 'Potholes',
    description: 'A huge crack or hole in the road',
    imagePath: 'assets/images/pothole_report.webp',
    type: ReportCategoryType.pothole,
  ),
  ReportCategory(
    label: 'Utility Poles',
    description: 'Leaning or fallen utility pole',
    imagePath: 'assets/images/utility_pole_report.webp',
    type: ReportCategoryType.utilityPole,
  ),
  ReportCategory(
    label: 'Road Concerns',
    description: 'General road issues',
    imagePath: 'assets/images/road_concerns.webp',
    type: ReportCategoryType.roadConcern,
  ),
];
