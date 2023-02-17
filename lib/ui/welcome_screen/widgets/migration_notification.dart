import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/resources/l10n.dart';

class MigrationNotification extends StatelessWidget {
  const MigrationNotification({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: primaryRed,
      child: Column(
        children: [
          Text(
            l10n.migration_v1_to_v2_1,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.migration_v1_to_v2_2,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          const CircularProgressIndicator(
            color: Colors.yellow,
          ),
          const SizedBox(height: 10),
          Text(
            '10 / 10 ${l10n.restored}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
