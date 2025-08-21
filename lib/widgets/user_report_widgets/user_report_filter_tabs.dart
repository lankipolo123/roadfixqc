import 'package:flutter/material.dart';

class ReportFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const ReportFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: 0, label: Text('All')),
        ButtonSegment(value: 1, label: Text('Pending')),
        ButtonSegment(value: 2, label: Text('Resolved')),
        ButtonSegment(value: 3, label: Text('Rejected')),
      ],
      selected: {selectedIndex},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
