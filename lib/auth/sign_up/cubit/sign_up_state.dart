part of 'sign_up_cubit.dart';

@immutable
abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignedUp extends SignUpState {}

class SignUpFailed extends SignUpState {}

class SigningUp extends SignUpState{}

class SignUpError extends SignUpState{}
