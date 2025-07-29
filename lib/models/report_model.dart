enum ReportStatus { pending, resolved, rejected }

class Report {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final ReportStatus status;
  final String? imageUrl;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    this.imageUrl,
  });
}
