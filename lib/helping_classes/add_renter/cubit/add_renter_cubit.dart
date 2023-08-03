import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../database/database.dart';

part 'add_renter_state.dart';

class AddRenterCubit extends Cubit<AddRenterState> {
  AddRenterCubit() : super(AddRenterInitial());

  Future<void> addRenter(String buildingID, String renterName, DateTime startDate, double rent, int frequency, String? apartNum) async {
    emit(AddingRenter());
    try{
      await Database().addRenter(
        buildingID,
        renterName,
        startDate.millisecondsSinceEpoch,
        rent,
        frequency,
        apartNum ?? '',
      );
      emit(AddedRenter(rent: rent*12/frequency));
    } catch (error){
      emit(AddRenterError());
    }
  }
}
