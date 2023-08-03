part of 'lease_termination_cubit.dart';

@immutable
abstract class LeaseTerminationState {}

class LeaseTerminationInitial extends LeaseTerminationState {}

class LeaseTerminating extends LeaseTerminationState {}

class LeaseTerminated extends LeaseTerminationState {
  final double rent;

  LeaseTerminated({required this.rent});
}

class LeaseTerminationError extends LeaseTerminationState {}