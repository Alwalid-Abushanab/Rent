import 'package:flutter/cupertino.dart';

class BuildingRenter{
  final String buildingID;
  final String renterID;
  final BuildContext context;
  final String buildingName;

  BuildingRenter({required this.buildingID, required this.renterID, required this.buildingName,required this.context});
}