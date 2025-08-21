import '../models/user_report_model.dart';

List<Report> mockReports = [
  Report(
    id: '1',
    title: 'Broken Street Light',
    description: 'Near 5th Avenue intersection.',
    date: DateTime.now().subtract(const Duration(days: 2)),
    status: ReportStatus.pending,
    imageUrl: null,
  ),
  Report(
    id: '2',
    title: 'Pothole in Road',
    description: 'In front of Greenwood High School.',
    date: DateTime.now().subtract(const Duration(days: 5)),
    status: ReportStatus.resolved,
    imageUrl: null,
  ),
  Report(
    id: '3',
    title: 'Overflowing Garbage Bin',
    description: 'Corner of 8th and Pine Street.',
    date: DateTime.now().subtract(const Duration(days: 1)),
    status: ReportStatus.pending,
    imageUrl:
        'https://images.unsplash.com/photo-1602810316633-c06b3ba2d2e4?auto=format&fit=crop&w=400&q=60',
  ),
  Report(
    id: '4',
    title: 'Leaking Water Pipe',
    description: 'Outside building 12B, Sunset Blvd.',
    date: DateTime.now().subtract(const Duration(days: 7)),
    status: ReportStatus.resolved,
    imageUrl: null,
  ),
  Report(
    id: '5',
    title: 'Unauthorized Construction',
    description: 'Near City Market parking lot.',
    date: DateTime.now().subtract(const Duration(days: 3)),
    status: ReportStatus.rejected,
    imageUrl:
        'https://images.unsplash.com/photo-1523413039791-f9633a875f6b?auto=format&fit=crop&w=400&q=60',
  ),
  Report(
    id: '6',
    title: 'Fallen Tree Blocking Road',
    description: 'Maple Street, behind the community center.',
    date: DateTime.now().subtract(const Duration(hours: 12)),
    status: ReportStatus.pending,
    imageUrl:
        'https://images.unsplash.com/photo-1579165466471-2fd3ed7fd600?auto=format&fit=crop&w=400&q=60',
  ),
  Report(
    id: '7',
    title: 'Graffiti on Public Wall',
    description: 'Railway underpass near Central Park.',
    date: DateTime.now().subtract(const Duration(days: 10)),
    status: ReportStatus.resolved,
    imageUrl: null,
  ),
  Report(
    id: '8',
    title: 'Open Manhole',
    description: 'Just before the entrance to Block C.',
    date: DateTime.now().subtract(const Duration(days: 6)),
    status: ReportStatus.rejected,
    imageUrl:
        'https://images.unsplash.com/photo-1596812113660-c9ce73ef2761?auto=format&fit=crop&w=400&q=60',
  ),
  Report(
    id: '9',
    title: 'Damaged Traffic Sign',
    description: 'Next to the main traffic light on King’s Road.',
    date: DateTime.now().subtract(const Duration(days: 4)),
    status: ReportStatus.pending,
    imageUrl: null,
  ),
  Report(
    id: '10',
    title: 'Street Flooding',
    description: 'Water logging at Palm Street after rainfall.',
    date: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
    status: ReportStatus.pending,
    imageUrl:
        'https://images.unsplash.com/photo-1549921296-3a6b74a0b9db?auto=format&fit=crop&w=400&q=60',
  ),
  Report(
    id: '11',
    title: 'Broken Bench in Park',
    description: 'Playground area of Riverside Park.',
    date: DateTime.now().subtract(const Duration(days: 8)),
    status: ReportStatus.pending,
    imageUrl: null,
  ),
];
