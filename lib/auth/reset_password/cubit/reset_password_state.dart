part of 'reset_password_cubit.dart';

@immutable
abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResettingPassword extends ResetPasswordState {}

class ResetPasswordError extends ResetPasswordState {}

class ResetPasswordEmailSent extends ResetPasswordState {}

class ResetPasswordFailed extends ResetPasswordState {}

