import 'package:rent/helping_classes/building_info.dart';

class RenterInfo{
  BuildingInfo buildingInfo;
  final String renterID;
  final String renterName;
  int paymentFrequency;
  final DateTime nextPaymentDate;
  final DateTime startDate;
  final List<int> payments;
  final String? apartmentNum;
  double rent;
  final DateTime? terminationDate;
  final int renterNotificationID;

  RenterInfo({
    required this.buildingInfo,
    required this.renterID,
    required this.startDate,
    required this.renterName,
    required this.paymentFrequency,
    required this.nextPaymentDate,
    required this.payments,
    required this.rent,
    required this.renterNotificationID,
    this.apartmentNum,
    this.terminationDate,
  });

  updateRentData(double rent, int paymentFrequency){
    this.rent = rent;
    this.paymentFrequency = paymentFrequency;
  }

  updateBuildingInfo(BuildingInfo newBuildingInfo){
    buildingInfo = newBuildingInfo;
  }
}