part of 'edit_property_cubit.dart';

@immutable
abstract class EditPropertyState {}

class EditPropertyInitial extends EditPropertyState {}

class EditingProperty extends EditPropertyState {}

class EditedProperty extends EditPropertyState {
  final String newName;
  EditedProperty({required this.newName});
}

class EditPropertyError extends EditPropertyState {}
