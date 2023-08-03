part of 'add_renter_cubit.dart';

@immutable
abstract class AddRenterState {}

class AddRenterInitial extends AddRenterState {}

class AddedRenter extends AddRenterState {
  final double rent;

  AddedRenter({required this.rent});
}

class AddingRenter extends AddRenterState {}

class AddRenterError extends AddRenterState {}
