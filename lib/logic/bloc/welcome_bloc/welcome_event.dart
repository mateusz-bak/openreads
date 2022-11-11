part of 'welcome_bloc.dart';

abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();
}

class ChangeWelcomeEvent extends WelcomeEvent {
  const ChangeWelcomeEvent(this.showWelcome);

  final bool showWelcome;

  @override
  List<Object?> get props => [showWelcome];
}
