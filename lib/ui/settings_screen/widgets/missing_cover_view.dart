import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class MissingCoverView extends StatelessWidget {
  const MissingCoverView({
    super.key,
    this.coverFile,
  });

  final File? coverFile;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: coverFile != null
          ? Image.file(
              coverFile!,
              fit: BoxFit.cover,
              width: (MediaQuery.of(context).size.width - 20 - 20 - 15) / 4,
            )
          : const SizedBox(),
    );
  }
}
