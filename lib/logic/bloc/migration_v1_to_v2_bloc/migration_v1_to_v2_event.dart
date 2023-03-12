part of 'migration_v1_to_v2_bloc.dart';

abstract class MigrationV1ToV2Event extends Equatable {
  const MigrationV1ToV2Event();
}

class StartMigration extends MigrationV1ToV2Event {
  final BuildContext context;
  final bool retrigger;

  const StartMigration({
    required this.context,
    this.retrigger = false,
  });

  @override
  List<Object?> get props => [
        context,
        retrigger,
      ];
}
