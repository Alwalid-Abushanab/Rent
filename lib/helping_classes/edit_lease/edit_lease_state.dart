part of 'edit_lease_cubit.dart';

@immutable
abstract class EditLeaseState {}

class EditLeaseInitial extends EditLeaseState {}

class EditingLease extends EditLeaseState {}

class EditedLease extends EditLeaseState {
  final double rent;
  final int paymentFrequency;
  EditedLease({required this.rent, required this.paymentFrequency});
}

class EditLeaseError extends EditLeaseState {}
