import 'package:flutter/cupertino.dart';
import 'package:rent/helping_classes/renter_info.dart';

class ApartmentRenterInfo{
  RenterInfo renterInfo;
  final BuildContext apartmentBuildingContext;

  ApartmentRenterInfo({required this.renterInfo, required this.apartmentBuildingContext});

  updateRenterInfo(RenterInfo renterInfo){
    this.renterInfo = renterInfo;
  }
}