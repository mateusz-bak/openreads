import 'package:flutter_bloc/flutter_bloc.dart';

class BackupProgressCubit extends Cubit<String?> {
  BackupProgressCubit() : super(null);

  void updateString(String progress) {
    emit(progress);
  }

  void resetString() {
    emit(null);
  }
}
