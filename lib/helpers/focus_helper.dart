import 'package:flutter/material.dart';

class FocusHelper {
  static void next(BuildContext context, FocusNode? nextNode) {
    if (nextNode != null) {
      FocusScope.of(context).requestFocus(nextNode);
    } else {
      FocusScope.of(context).unfocus();
    }
  }
}
