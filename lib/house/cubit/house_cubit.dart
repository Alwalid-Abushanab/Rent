import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../database/database.dart';
part 'house_state.dart';

class HouseCubit extends Cubit<HouseState> {
  final String buildingID;
  HouseCubit({required this.buildingID}) : super(HouseInitial());

  Future<void> loadRenter() async {
    emit(HouseLoading());
    try{
      final renter = await Database().getRenters(buildingID);
      final hasPrevRenters = await Database().hasPreviousRenters(buildingID);

      if(renter!.isEmpty){
        emit(HouseEmpty(hasPrevRenters: hasPrevRenters));
      } else{
        List<dynamic> paymentsDynamic = renter[0]['Payments'];

        emit(HouseLoaded(
          renterID: renter[0].id,
          renterName: renter[0]['Name'],
          startDate: DateTime.fromMillisecondsSinceEpoch(renter[0]['StartDate']),
          paymentFrequency: renter[0]['PaymentFrequency'],
          nextPaymentDate: DateTime.fromMillisecondsSinceEpoch(renter[0]['NextPaymentDate']),
          payments: paymentsDynamic.map((element) => int.parse(element)).toList(),
          rent: renter[0]['Rent'],
          hasPrevRenters: hasPrevRenters,
        ));
      }
    } catch (error){
      emit(HouseError());
    }
  }
}
