part of 'google_sign_in_cubit.dart';

@immutable
abstract class GoogleSignInState {}

class GoogleSignInInitial extends GoogleSignInState {}

class GoogleLoggedIn extends GoogleSignInState {}

class GoogleLoading extends GoogleSignInState {}

class GoogleError extends GoogleSignInState {
  final String message;

  GoogleError({required this.message});
}