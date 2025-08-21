import 'package:flutter/material.dart';

class ReportForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  const ReportForm({super.key, required this.formKey, required this.children});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(children: children),
    );
  }
}
