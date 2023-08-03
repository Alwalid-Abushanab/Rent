import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/add_renter/cubit/add_renter_cubit.dart';
import 'package:rent/helping_classes/delete_property/delete_property_cubit.dart';
import 'package:rent/helping_classes/edit_lease/edit_lease_cubit.dart';
import 'package:rent/helping_classes/edit_property/edit_property_cubit.dart';
import '../helping_classes/lease_termination/lease_termination_cubit.dart';
import 'package:rent/helping_classes/pay_dialog/cubit/pay_dialog_cubit.dart';
import 'package:rent/helping_classes/pop_up_menu.dart';
import 'package:rent/helping_classes/renter_info.dart';
import 'package:rent/house/cubit/house_cubit.dart';
import 'package:rent/property/property_tile/cubit/property_tile_cubit.dart';
import 'package:rent/routes/route_generator.dart';
import '../helping_classes/building_info.dart';
import '../helping_classes/help_methods.dart';
import '../helping_classes/notifications.dart';
import '../helping_classes/restore_renter/restore_renter_cubit.dart';

class HouseView extends StatefulWidget {
  final BuildingInfo buildingInfo;
  const HouseView({super.key, required this.buildingInfo});

  @override
  State<HouseView> createState() => _HouseViewState();
}

class _HouseViewState extends State<HouseView> {
  late BuildingInfo buildingInfo;
  RenterInfo? renterInfo;
  late bool _isLoading;
  late bool hasPrevRenters;

  @override
  initState() {
    super.initState();
    buildingInfo = widget.buildingInfo;
    _isLoading = true;
    BlocProvider.of<HouseCubit>(context).loadRenter();
  }

  @override
  Widget build(BuildContext context) {
    return propertyDeletionListener();
  }

  Widget propertyDeletionListener(){
    return BlocListener<DeletePropertyCubit, DeletePropertyState>(
      listener: (context, state) {
        if(state is DeletedProperty){
          Navigator.pop(context);
          Notifications().unScheduleNotification(id: buildingInfo.buildingNotificationID);
          Navigator.pushNamed(context, RouteGenerator.homePage);
          showMessage(context, "Property has been deleted successfully");
        } else if(state is DeletingProperty){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is DeletePropertyError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: leaseTerminationListener(),
    );
  }

  Widget leaseTerminationListener(){
    return BlocListener<LeaseTerminationCubit, LeaseTerminationState>(
      listener: (context, state) {
        if(state is LeaseTerminated){
          Navigator.pop(context);
          Notifications().unScheduleNotification(id: buildingInfo.buildingNotificationID);
          setState(() {
            buildingInfo.updateBuildingRent(0.0);
            renterInfo = null;
            hasPrevRenters = true;
          });
          BlocProvider.of<PropertyTileCubit>(buildingInfo.tileContext!).updateBuildingInfo(buildingInfo);

          showMessage(context, "Lease has been terminated successfully");
        } else if(state is LeaseTerminating){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is LeaseTerminationError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: propertyEditingListener(),
    );
  }

  Widget propertyEditingListener(){
    return BlocListener<EditPropertyCubit, EditPropertyState>(
      listener: (context, state) {
        if(state is EditedProperty){
          Navigator.pop(context);

          setState(() {
            buildingInfo.updateBuildingName(state.newName);
          });

          BlocProvider.of<PropertyTileCubit>(buildingInfo.tileContext!).updateBuildingInfo(buildingInfo);

          showMessage(context, "building name has been updated successfully");
        } else if(state is EditingProperty){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is EditPropertyError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
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
            buildingInfo.updateBuildingRent(state.rent*12/state.paymentFrequency);
            renterInfo!.updateRentData(state.rent, state.paymentFrequency);
            renterInfo!.updateBuildingInfo(buildingInfo);
          });
          BlocProvider.of<PropertyTileCubit>(buildingInfo.tileContext!).updateBuildingInfo(buildingInfo);

          showMessage(context, "rent has been updated successfully");
        } else if(state is EditingLease){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is EditLeaseError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: renterAddingListener(),
    );
  }

  Widget renterAddingListener(){
    return BlocListener<AddRenterCubit, AddRenterState>(
      listener: (context, state) {
        if(state is AddedRenter){
          Navigator.pop(context);

          setState(() {
            buildingInfo.updateBuildingRent(state.rent);
          });
          BlocProvider.of<HouseCubit>(context).loadRenter();
          BlocProvider.of<PropertyTileCubit>(buildingInfo.tileContext!).updateBuildingInfo(buildingInfo);

          showMessage(context, "Renter has been added successfully");
        } else if(state is AddingRenter){
          showProgressIndicator(context);
        } else if(state is AddRenterError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: renterRestorationListener(),
    );
  }

  Widget renterRestorationListener(){
    return BlocListener<RestoreRenterCubit, RestoreRenterState>(
      listener: (context, state) {
        if(state is RestoredRenter){
          BlocProvider.of<HouseCubit>(context).loadRenter();
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          showMessage(context, "Renter Has Been Restored successfully");
        } else if(state is RestoringRenter){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is RestoreRenterError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: paymentDialogListener(),
    );
  }



  Widget paymentDialogListener(){
    return BlocListener<PayDialogCubit, PayDialogState>(
      listener: (context, state) {
        if(state is PayDialogPaid){
          Navigator.pop(context);
          setState(() {
            renterInfo = state.renterInfo;
          });
        } else if(state is PayDialogFileNotSelected){
          showMessage(context, 'No File was selected');
        } else if(state is PayDialogInvalidFile){
          showMessage(context, 'Invalid File type, You can only share pictures of type png or jpg');
        } else if(state is PayDialogLoading){
          showProgressIndicator(context);
        }
      },
      child: houseListener(),
    );
  }

  Widget houseListener(){
    return BlocListener<HouseCubit, HouseState>(
      listener: (context, state) {
        if(state is HouseError){
          _isLoading = true;
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        } else if(state is HouseLoaded){
          setState(() {
            renterInfo = RenterInfo(
              buildingInfo: buildingInfo,
              renterID: state.renterID,
              renterName: state.renterName,
              paymentFrequency: state.paymentFrequency,
              nextPaymentDate: state.nextPaymentDate,
              payments: state.payments,
              startDate: state.startDate,
              rent: state.rent,
              renterNotificationID: buildingInfo.buildingNotificationID,
            );
            hasPrevRenters = state.hasPrevRenters;
            _isLoading = false;
            setNotification(renterInfo!);
          });
        } else if(state is HouseEmpty){
          setState(() {
            hasPrevRenters = state.hasPrevRenters;
            _isLoading = false;
          });
        } else if(state is HouseLoading){
          setState(() {
            _isLoading = true;
          });
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: _isLoading
              ? const Text('Loading Property')
              : Text(buildingInfo.buildingName),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: menu(
                context: context,
                prevRentersItem: _isLoading ? null : previousRentersItem(context, buildingInfo, hasPrevRenters, renterInfo == null, _isLoading),
                leaseTerminationItem: renterInfo != null ? terminateLeaseItem(context,renterInfo!, _isLoading) : null,
                propertyDeletionItem: deletePropertyItem(context, buildingInfo.buildingID, _isLoading),
                leaseEditingItem: renterInfo != null ? editLeaseItem(context, renterInfo!, _isLoading) : null,
                propertyEditingItem: editPropertyItem(context, buildingInfo, _isLoading),),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : renterInfo == null
            ? noRenters<HouseCubit>(
              context,
              BlocProvider.of<HouseCubit>(context),
              'This ${buildingInfo.buildingType} currently is not being rented. Please use the + button to add a renter',
              buildingInfo, )
            : renterInfoWidget(renterInfo!),
      ),
    );
  }
}