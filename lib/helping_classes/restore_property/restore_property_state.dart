part of 'restore_property_cubit.dart';

@immutable
abstract class RestorePropertyState {}

class RestorePropertyInitial extends RestorePropertyState {}

class RestoringProperty extends RestorePropertyState {}

class RestoredProperty extends RestorePropertyState {}

class RestorePropertyError extends RestorePropertyState {}