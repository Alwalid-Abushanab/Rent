import 'package:flutter/cupertino.dart';

class BuildingInfo{
  final BuildContext? tileContext;
  final String buildingID;
  String buildingName;
  final String buildingAddress;
  final String buildingType;
  double buildingRent;
  final int buildingNotificationID;

  BuildingInfo({
    this.tileContext,
    required this.buildingID,
    required this.buildingName,
    required this.buildingAddress,
    required this.buildingType,
    required this.buildingRent,
    required this.buildingNotificationID,
  });

  updateBuildingName(String name){
    buildingName = name;
  }

  updateBuildingRent(double rent){
    buildingRent = rent;
  }
}