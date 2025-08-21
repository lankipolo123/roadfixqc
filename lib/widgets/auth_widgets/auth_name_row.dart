import 'package:flutter/material.dart';
import 'custom_textfield.dart';

class NameRow extends StatelessWidget {
  final TextEditingController? firstNameController;
  final TextEditingController? lastNameController;
  final TextEditingController? middleInitialController;
  final FocusNode? firstNameFocus;
  final FocusNode? lastNameFocus;
  final FocusNode? middleInitialFocus;
  final FocusNode? nextFocus;
  final String firstNameLabel;
  final String lastNameLabel;
  final String middleInitialLabel;

  const NameRow({
    super.key,
    this.firstNameController,
    this.lastNameController,
    this.middleInitialController,
    this.firstNameFocus,
    this.lastNameFocus,
    this.middleInitialFocus,
    this.nextFocus,
    this.firstNameLabel = 'First Name',
    this.lastNameLabel = 'Last Name',
    this.middleInitialLabel = 'MI',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomTextField(
            label: firstNameLabel,
            controller: firstNameController,
            focusNode: firstNameFocus,
            onNext: () {
              if (middleInitialFocus != null) {
                FocusScope.of(context).requestFocus(middleInitialFocus);
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: CustomTextField(
            label: middleInitialLabel,
            controller: middleInitialController,
            focusNode: middleInitialFocus,
            onNext: () {
              if (lastNameFocus != null) {
                FocusScope.of(context).requestFocus(lastNameFocus);
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: CustomTextField(
            label: lastNameLabel,
            controller: lastNameController,
            focusNode: lastNameFocus,
            onNext: () {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              }
            },
          ),
        ),
      ],
    );
  }
}
