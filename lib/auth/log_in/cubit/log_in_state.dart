part of 'log_in_cubit.dart';

@immutable
abstract class LogInState {}

class LogInInitial extends LogInState {}

class LoggingIn extends LogInState {}

class LoggedIn extends LogInState {}

class LogInFailed extends LogInState {}

class LogInError extends LogInState {}
