part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object> get props => [];
}

class StatsLoad extends StatsEvent {
  final List<Book> books;

  const StatsLoad(
    this.books,
  );

  @override
  List<Object> get props => [books];
}
