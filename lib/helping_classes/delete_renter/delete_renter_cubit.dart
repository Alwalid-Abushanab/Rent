import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'delete_renter_state.dart';

class DeleteRenterCubit extends Cubit<DeleteRenterState> {
  DeleteRenterCubit() : super(DeleteRenterInitial());

  deleteRenter(String buildingID, String renterID) async {
    emit(DeletingRenter());
    try {
      await Database().deleteRenter(buildingID, renterID);
      emit(DeletedRenter());
    } catch (error){
      emit(DeleteRenterError());
    }
  }
}
