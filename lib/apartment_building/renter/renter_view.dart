import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/apartment_building/cubit/apartment_building_cubit.dart';
import 'package:rent/helping_classes/help_methods.dart';
import '../../helping_classes/edit_lease/edit_lease_cubit.dart';
import '../../helping_classes/pay_dialog/cubit/pay_dialog_cubit.dart';
import '../../helping_classes/pop_up_menu.dart';
import '../../property/property_tile/cubit/property_tile_cubit.dart';
import 'apt_renter_info.dart';


class RenterView extends StatefulWidget{
  final ApartmentRenterInfo apartmentRenterInfo;
  const RenterView({super.key, required this.apartmentRenterInfo});

  @override
  State<RenterView> createState() => _RenterViewState();
}

class _RenterViewState extends State<RenterView>{
  bool reLoadRenters = false;
  late ApartmentRenterInfo apartmentRenterInfo;

  @override
  void initState() {
    super.initState();
    apartmentRenterInfo = widget.apartmentRenterInfo;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if(reLoadRenters){
          BlocProvider.of<ApartmentBuildingCubit>(apartmentRenterInfo.apartmentBuildingContext).loadRenters();
        }
        return Future.value(true);
      },
      child: leaseEditingListener(),
    );
  }

  Widget leaseEditingListener(){
    return BlocListener<EditLeaseCubit, EditLeaseState>(
      listener: (context, state) {
        if(state is EditedLease){
          Navigator.pop(context);
          setState(() {
            double newRent = apartmentRenterInfo.renterInfo.buildingInfo.buildingRent + ((state.rent*12/state.paymentFrequency)-(apartmentRenterInfo.renterInfo.rent*12/apartmentRenterInfo.renterInfo.paymentFrequency));
            apartmentRenterInfo.renterInfo.buildingInfo.updateBuildingRent(newRent);
            apartmentRenterInfo.renterInfo.updateRentData(state.rent, state.paymentFrequency);
          });
          BlocProvider.of<PropertyTileCubit>(apartmentRenterInfo.renterInfo.buildingInfo.tileContext!).updateBuildingInfo(apartmentRenterInfo.renterInfo.buildingInfo);
          BlocProvider.of<ApartmentBuildingCubit>(apartmentRenterInfo.apartmentBuildingContext).updateRent(apartmentRenterInfo.renterInfo.buildingInfo.buildingRent);
          showMessage(context, "rent has been updated successfully");
        } else if(state is EditingLease){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is EditLeaseError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: payDialogListener(),
    );
  }

  Widget payDialogListener(){
    return BlocListener<PayDialogCubit, PayDialogState>(
      listener: (context, state) {
        if(state is PayDialogPaid){
          Navigator.pop(context);
          reLoadRenters = true;
          setNotification(widget.apartmentRenterInfo.renterInfo);
          setState(() {
            apartmentRenterInfo.updateRenterInfo(state.renterInfo);
          });
        } else if(state is PayDialogFileNotSelected){
          showMessage(context, 'No File was selected');
        } else if(state is PayDialogInvalidFile){
          showMessage(context, 'Invalid File type, You can only share pictures of type png or jpg');
        } else if(state is PayDialogLoading){
          showProgressIndicator(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(apartmentRenterInfo.renterInfo.renterName),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: menu(
                context: context,
                leaseTerminationItem: terminateLeaseItem(apartmentRenterInfo.apartmentBuildingContext, apartmentRenterInfo.renterInfo, false),
                leaseEditingItem: editLeaseItem(context, apartmentRenterInfo.renterInfo, false)
              ),
            ),
          ],
        ),
        body: renterInfoWidget(apartmentRenterInfo.renterInfo),
      ),
    );
  }
}