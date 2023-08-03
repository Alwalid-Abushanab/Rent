part of 'permanently_delete_property_cubit.dart';

@immutable
abstract class PermanentlyDeletePropertyState {}

class PermanentlyDeletePropertyInitial extends PermanentlyDeletePropertyState {}

class PermanentlyDeletingProperty extends PermanentlyDeletePropertyState {}

class PermanentlyDeletedProperty extends PermanentlyDeletePropertyState {}

class PermanentlyDeletePropertyError extends PermanentlyDeletePropertyState {}