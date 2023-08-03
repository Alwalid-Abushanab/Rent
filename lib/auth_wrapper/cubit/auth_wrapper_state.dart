part of 'auth_wrapper_cubit.dart';

@immutable
abstract class AuthWrapperState {}

class AuthWrapperInitial extends AuthWrapperState {}

class AuthWrapperSignedIn extends AuthWrapperState {}

class AuthWrapperSignedOut extends AuthWrapperState {}