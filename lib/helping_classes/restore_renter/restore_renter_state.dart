part of 'restore_renter_cubit.dart';

@immutable
abstract class RestoreRenterState {}

class RestoreRenterInitial extends RestoreRenterState {}

class RestoringRenter extends RestoreRenterState {}

class RestoredRenter extends RestoreRenterState {}

class RestoreRenterError extends RestoreRenterState {}