import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'previous_properties_state.dart';

class PreviousPropertiesCubit extends Cubit<PreviousPropertiesState> {
  PreviousPropertiesCubit() : super(PreviousPropertiesInitial());

  Future<void> loadPreviousProperties() async {
    emit(PreviousPropertiesLoading());
    try{
      final properties = await Database().getPreviousProperties();
      emit(PreviousPropertiesLoaded(properties: properties));
    } catch (error){
      emit(PreviousPropertiesError());
    }
  }

  Future<void> loadRenters(String buildingID) async {
    emit(PreviousPropertiesLoading());
    try{
      final renters = await Database().getPreviousBuildingRenters(buildingID);

      emit(RentersLoaded(renters: renters));
    } catch (error){
      emit(PreviousPropertiesError());
    }
  }
}
