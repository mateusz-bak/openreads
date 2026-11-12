import 'dart:io';

import 'package:flutter/material.dart';

Widget buildPlatformSpecificAlertDialog({
  required Widget title,
  Widget? content,
  List<Widget>? actions,
  MainAxisAlignment? actionsAlignment,
  EdgeInsets? contentPadding,
  RoundedRectangleBorder? shape,
}) {
  if (Platform.isLinux) {
    // For Linux, we use a standard AlertDialog. Maybe it'll work well for
    // other desktop platforms too, not tested.
    return AlertDialog(
      title: title,
      content: content,
      actionsAlignment: actionsAlignment,
      actions: actions,
      contentPadding: contentPadding,
      shape: shape,
    );
  } else {
    // AlertDialog.adaptive is a standard helper function to choose iOS and
    // Android.
    return AlertDialog.adaptive(
      title: title,
      content: content,
      actionsAlignment: actionsAlignment,
      actions: actions,
      contentPadding: contentPadding,
      shape: shape,
    );
  }
}
