import 'package:flutter/cupertino.dart';
import 'package:rent/helping_classes/building_info.dart';

class PreviousRentersInfo{
  final BuildContext context;
  final BuildingInfo buildingInfo;
  final bool buildingHasSpace;

  PreviousRentersInfo({required this.buildingInfo, required this.context, required this.buildingHasSpace});
}