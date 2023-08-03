import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'permanently_delete_property_state.dart';

class PermanentlyDeletePropertyCubit extends Cubit<PermanentlyDeletePropertyState> {
  PermanentlyDeletePropertyCubit() : super(PermanentlyDeletePropertyInitial());

  permanentlyDeleteProperty(String buildingID) async {
    emit(PermanentlyDeletingProperty());
    try {
      await Database().permanentlyDeleteProperty(buildingID);
      emit(PermanentlyDeletedProperty());
    } catch (error){
      emit(PermanentlyDeletePropertyError());
    }
  }
}
