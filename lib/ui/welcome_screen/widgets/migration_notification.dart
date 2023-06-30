import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class MigrationNotification extends StatelessWidget {
  const MigrationNotification({
    super.key,
    this.total,
    this.done,
    this.error,
    this.success,
  });

  final int? total;
  final int? done;
  final String? error;
  final bool? success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: primaryRed,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          )),
      child: Column(
        children: [
          Text(
            success == true
                ? LocaleKeys.migration_v1_to_v2_finished.tr()
                : LocaleKeys.migration_v1_to_v2_1.tr(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: success == true ? 0 : 10),
          success == true
              ? const SizedBox()
              : Text(
                  LocaleKeys.migration_v1_to_v2_2.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
          SizedBox(height: success == true ? 0 : 10),
          success == true
              ? const SizedBox()
              : const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.yellow,
                  ),
                ),
          SizedBox(height: success == true ? 0 : 8),
          error != null
              ? Text(
                  error!,
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              : const SizedBox(),
          success == true
              ? const SizedBox()
              : Text(
                  (total != null && done != null)
                      ? '$done / $total ${LocaleKeys.restored.tr()}'
                      : total != null
                          ? '0 / $total ${LocaleKeys.restored.tr()}'
                          : '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
          SizedBox(height: success == true ? 0 : 10),
        ],
      ),
    );
  }
}
