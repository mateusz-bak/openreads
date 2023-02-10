part of 'welcome_bloc.dart';

abstract class WelcomeState extends Equatable {
  const WelcomeState();
}

class ShowWelcomeState extends WelcomeState {
  @override
  List<Object> get props => [];
}

class HideWelcomeState extends WelcomeState {
  @override
  List<Object> get props => [];
}
