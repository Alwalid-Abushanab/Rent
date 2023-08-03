import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'edit_lease_state.dart';

class EditLeaseCubit extends Cubit<EditLeaseState> {
  EditLeaseCubit() : super(EditLeaseInitial());

  editLease(String buildingID, String renterID, double oldRent, double newRent, int newPaymentFrequency) async {
    emit(EditingLease());
    try {
      await Database().updateLease(buildingID, renterID, oldRent, newRent, newPaymentFrequency);
      emit(EditedLease(rent: newRent, paymentFrequency: newPaymentFrequency));
    } catch (error){
      emit(EditLeaseError());
    }
  }
}
