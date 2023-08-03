import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'delete_property_state.dart';

class DeletePropertyCubit extends Cubit<DeletePropertyState> {
  DeletePropertyCubit() : super(DeletePropertyInitial());

  deleteProperty(String buildingID) async {
    emit(DeletingProperty());
    try {
      await Database().deleteProperty(buildingID);
      emit(DeletedProperty());
    } catch (error){
      emit(DeletePropertyError());
    }
  }
}
