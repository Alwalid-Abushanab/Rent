import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'restore_property_state.dart';

class RestorePropertyCubit extends Cubit<RestorePropertyState> {
  RestorePropertyCubit() : super(RestorePropertyInitial());

  restoreProperty(String buildingID) async {
    emit(RestoringProperty());
    try {
      await Database().restoreProperty(buildingID);
      emit(RestoredProperty());
    } catch (error){
      emit(RestorePropertyError());
    }
  }
}
