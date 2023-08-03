import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'restore_renter_state.dart';

class RestoreRenterCubit extends Cubit<RestoreRenterState> {
  RestoreRenterCubit() : super(RestoreRenterInitial());

  restoreRenter(String buildingID, String renterID, double yearlyRent) async {
    emit(RestoringRenter());
    try {
      await Database().restoreRenter(buildingID, renterID, yearlyRent);
      emit(RestoredRenter());
    } catch (error){
      emit(RestoreRenterError());
    }
  }
}
