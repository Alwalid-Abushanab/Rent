import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'edit_property_state.dart';

class EditPropertyCubit extends Cubit<EditPropertyState> {
  EditPropertyCubit() : super(EditPropertyInitial());

  editProperty(String buildingID, String newName) async {
    emit(EditingProperty());
    try {
      await Database().updateProperty(buildingID, newName);
      emit(EditedProperty(newName: newName));
    } catch (error){
      emit(EditPropertyError());
    }
  }
}
