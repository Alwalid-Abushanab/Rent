import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rent/helping_classes/building_info.dart';
part 'property_tile_state.dart';

class PropertyTileCubit extends Cubit<PropertyTileState> {
  PropertyTileCubit() : super(PropertyTileInitial());

  updateBuildingInfo(BuildingInfo buildingInfo){
    emit(PropertyTileUpdated(buildingInfo:buildingInfo));
  }
}
