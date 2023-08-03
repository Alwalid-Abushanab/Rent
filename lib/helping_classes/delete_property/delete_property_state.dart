part of 'delete_property_cubit.dart';

@immutable
abstract class DeletePropertyState {}

class DeletePropertyInitial extends DeletePropertyState {}

class DeletingProperty extends DeletePropertyState {}

class DeletedProperty extends DeletePropertyState {}

class DeletePropertyError extends DeletePropertyState {}