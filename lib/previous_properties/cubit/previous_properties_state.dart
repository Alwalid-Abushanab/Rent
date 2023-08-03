part of 'previous_properties_cubit.dart';

@immutable
abstract class PreviousPropertiesState {}

class PreviousPropertiesInitial extends PreviousPropertiesState {}

class PreviousPropertiesLoading extends PreviousPropertiesState {}

class PreviousPropertiesLoaded extends PreviousPropertiesState {
  final List<dynamic> properties;
  PreviousPropertiesLoaded({required this.properties});
}

class PreviousPropertiesError extends PreviousPropertiesState {}

class RentersLoaded extends PreviousPropertiesState {
  final List<dynamic> renters;
  RentersLoaded({required this.renters});
}
