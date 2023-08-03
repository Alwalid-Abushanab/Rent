part of 'pay_dialog_cubit.dart';

@immutable
abstract class PayDialogState {}

class PayDialogInitial extends PayDialogState {}

class PayDialogPaid extends PayDialogState {
  final RenterInfo renterInfo;

  PayDialogPaid({required this.renterInfo});
}

class PayDialogInvalidFile extends PayDialogState {}

class PayDialogFileNotSelected extends PayDialogState {}

class PayDialogLoading extends PayDialogState {}


