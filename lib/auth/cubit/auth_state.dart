part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLogIn extends AuthState {}

class AuthSignUp extends AuthState {}

class AuthResetPassword extends AuthState {}

class AuthError extends AuthState {}