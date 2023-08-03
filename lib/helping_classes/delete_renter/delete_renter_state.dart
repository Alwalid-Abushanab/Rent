part of 'delete_renter_cubit.dart';

@immutable
abstract class DeleteRenterState {}

class DeleteRenterInitial extends DeleteRenterState {}

class DeletingRenter extends DeleteRenterState {}

class DeletedRenter extends DeleteRenterState {}

class DeleteRenterError extends DeleteRenterState {}
