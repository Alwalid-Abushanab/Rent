import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rent/database/database.dart';

part 'lease_termination_state.dart';

class LeaseTerminationCubit extends Cubit<LeaseTerminationState> {
  LeaseTerminationCubit() : super(LeaseTerminationInitial());

  Future<void> terminateLease(String buildingID, String renterID, double yearlyRent) async {
    emit(LeaseTerminating());
    try{
      await Database().terminateLease(buildingID, renterID, yearlyRent);
      emit(LeaseTerminated(rent: yearlyRent));
    } catch (error){
      emit(LeaseTerminationError());
    }
  }
}