import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meta/meta.dart';
import 'package:rent/helping_classes/renter_info.dart';

import '../../../database/database.dart';

part 'pay_dialog_state.dart';

class PayDialogCubit extends Cubit<PayDialogState> {
  PayDialogCubit() : super(PayDialogInitial());

  Future<void> getFile(RenterInfo renterInfo) async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['png','jpg']
    );

    if (result == null){
      emit(PayDialogFileNotSelected());
    } else if(result.files.single.extension! != 'png' && result.files.single.extension! != 'jpg'){
      emit(PayDialogInvalidFile());
    } else {
      emit(PayDialogLoading());
      final file = File(result.files.single.path!);
      await Database().saveReceipt(
        file,
        renterInfo,
      );
      paid(renterInfo);
    }
  }

  void payWithoutReceipt(RenterInfo renterInfo){
    emit(PayDialogLoading());
    paid(renterInfo);
  }

  Future<void> paid(RenterInfo renterInfo) async {

    await Database().addPayment(
      renterInfo.renterID,
      renterInfo.nextPaymentDate.millisecondsSinceEpoch,
      renterInfo.paymentFrequency,
      renterInfo.buildingInfo.buildingID,
    );

    var snapshot = await Database().getRenterFromID(renterInfo.renterID, renterInfo.buildingInfo.buildingID);

    List<dynamic> paymentsDynamic = snapshot['Payments'];


    RenterInfo updated = RenterInfo(
      buildingInfo: renterInfo.buildingInfo,
      renterID: renterInfo.renterID,
      renterName: renterInfo.renterName,
      startDate: renterInfo.startDate,
      paymentFrequency: renterInfo.paymentFrequency,
      nextPaymentDate: DateTime.fromMillisecondsSinceEpoch(snapshot['NextPaymentDate']),
      payments: paymentsDynamic.map((element) => int.parse(element)).toList(),
      rent: renterInfo.rent,
      apartmentNum: renterInfo.apartmentNum,
      renterNotificationID: renterInfo.renterNotificationID,
    );

    emit(PayDialogPaid(renterInfo: updated));
  }
}
