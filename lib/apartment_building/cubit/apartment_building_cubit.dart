import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'apartment_building_state.dart';

class ApartmentBuildingCubit extends Cubit<ApartmentBuildingState> {
  final String buildingID;
  ApartmentBuildingCubit({required this.buildingID}) : super(ApartmentBuildingInitial());

  Future<void> loadRenters() async {
    emit(ApartmentBuildingLoading());
    try{
      final renters = await Database().getRenters(buildingID);
      final hasPrevRenters = await Database().hasPreviousRenters(buildingID);


      emit(ApartmentBuildingLoaded(
        renters: renters,
        hasPrevRenters: hasPrevRenters,
      ));
    } catch (error){
      emit(ApartmentBuildingError());
    }
  }

  updateRent(double rent){
    emit(ApartmentBuildingRentUpdating(rent: rent));
  }

  updated(){
    emit(ApartmentBuildingUpdated());
  }
}
