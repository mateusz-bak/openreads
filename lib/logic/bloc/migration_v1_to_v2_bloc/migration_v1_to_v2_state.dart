part of 'migration_v1_to_v2_bloc.dart';

abstract class MigrationV1ToV2State extends Equatable {
  const MigrationV1ToV2State();

  @override
  List<Object?> get props => [];
}

class MigrationNotStarted extends MigrationV1ToV2State {}

class MigrationOnging extends MigrationV1ToV2State {
  const MigrationOnging({
    this.total,
    this.done,
  });

  final int? total;
  final int? done;

  @override
  List<Object?> get props => [total, done];
}

class MigrationTriggered extends MigrationV1ToV2State {}

class MigrationSkipped extends MigrationV1ToV2State {}

class MigrationSucceded extends MigrationV1ToV2State {}

class MigrationFailed extends MigrationV1ToV2State {
  const MigrationFailed({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}
