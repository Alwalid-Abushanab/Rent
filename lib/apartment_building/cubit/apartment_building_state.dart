part of 'apartment_building_cubit.dart';

@immutable
abstract class ApartmentBuildingState {}

class ApartmentBuildingInitial extends ApartmentBuildingState {}


class ApartmentBuildingLoading extends ApartmentBuildingState {}

class ApartmentBuildingError extends ApartmentBuildingState {}

class ApartmentBuildingLoaded extends ApartmentBuildingState {
  final List<dynamic> renters;
  final bool hasPrevRenters;

  ApartmentBuildingLoaded({
    required this.renters,
    required this.hasPrevRenters
  });
}

class ApartmentBuildingRentUpdating extends ApartmentBuildingState{
  final double rent;
  ApartmentBuildingRentUpdating({required this.rent});
}

class ApartmentBuildingUpdated extends ApartmentBuildingState{}