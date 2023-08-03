part of 'property_tile_cubit.dart';

@immutable
abstract class PropertyTileState {}

class PropertyTileInitial extends PropertyTileState {}

class PropertyTileUpdated extends PropertyTileState {
  final BuildingInfo buildingInfo;

  PropertyTileUpdated({required this.buildingInfo});
}
