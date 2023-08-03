part of 'house_cubit.dart';

@immutable
abstract class HouseState {}

class HouseInitial extends HouseState {}

class HouseLoading extends HouseState {}

class HouseError extends HouseState {}

class HouseEmpty extends HouseState {
  final bool hasPrevRenters;
  HouseEmpty({required this.hasPrevRenters,});
}

class HouseLoaded extends HouseState {
  final String renterID;
  final String renterName;
  final DateTime startDate;
  final int paymentFrequency;
  final DateTime nextPaymentDate;
  final List<int> payments;
  final double rent;
  final bool hasPrevRenters;

  HouseLoaded({
    required this.renterID,
    required this.renterName,
    required this.startDate,
    required this.paymentFrequency,
    required this.nextPaymentDate,
    required this.payments,
    required this.rent,
    required this.hasPrevRenters,
  });
}