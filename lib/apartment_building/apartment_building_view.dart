import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/apartment_building/cubit/apartment_building_cubit.dart';
import 'package:rent/apartment_building/renter/apt_renter_info.dart';
import 'package:rent/helping_classes/renter_info.dart';
import '../helping_classes/add_renter/add_renter.dart';
import '../helping_classes/add_renter/cubit/add_renter_cubit.dart';
import '../helping_classes/building_info.dart';
import '../helping_classes/delete_property/delete_property_cubit.dart';
import '../helping_classes/edit_property/edit_property_cubit.dart';
import '../helping_classes/help_methods.dart';
import '../helping_classes/lease_termination/lease_termination_cubit.dart';
import '../helping_classes/notifications.dart';
import '../helping_classes/pop_up_menu.dart';
import '../helping_classes/restore_renter/restore_renter_cubit.dart';
import '../property/property_tile/cubit/property_tile_cubit.dart';
import '../routes/route_generator.dart';

class ApartmentBuildingView extends StatefulWidget {
  final BuildingInfo buildingInfo;
  const ApartmentBuildingView({super.key, required this.buildingInfo});

  @override
  State<ApartmentBuildingView> createState() => _ApartmentBuildingViewState();
}

class _ApartmentBuildingViewState extends State<ApartmentBuildingView> {
  late BuildingInfo buildingInfo;
  List<dynamic>? renters;
  late bool _isLoading;
  late bool hasPrevRenters;

  @override
  initState() {
    super.initState();
    _isLoading = true;
    buildingInfo = widget.buildingInfo;
    BlocProvider.of<ApartmentBuildingCubit>(context).loadRenters();
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
          for(int i = 0; i < renters!.length; i++){
            Notifications().unScheduleNotification(id: buildingInfo.buildingNotificationID+i);
          }
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
        if(state is LeaseTerminating){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is LeaseTerminated){
          Navigator.pop(context);
          setState(() {
            buildingInfo.updateBuildingRent(buildingInfo.buildingRent - state.rent);
          });
          BlocProvider.of<ApartmentBuildingCubit>(context).loadRenters();
          BlocProvider.of<PropertyTileCubit>(buildingInfo.tileContext!).updateBuildingInfo(buildingInfo);
          Navigator.pop(context);
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
      child: renterRestorationListener(),
    );
  }

  Widget renterRestorationListener(){
    return BlocListener<RestoreRenterCubit, RestoreRenterState>(
      listener: (context, state) {
        if(state is RestoredRenter){
          BlocProvider.of<ApartmentBuildingCubit>(context).loadRenters();
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
      child: renterAddingListener(),
    );
  }

  Widget renterAddingListener(){
    return BlocListener<AddRenterCubit, AddRenterState>(
      listener: (context, state) {
        if(state is AddedRenter){
          Navigator.pop(context);
          setState(() {
            buildingInfo.updateBuildingRent(buildingInfo.buildingRent + state.rent);
          });
          BlocProvider.of<ApartmentBuildingCubit>(context).loadRenters();
          BlocProvider.of<PropertyTileCubit>(buildingInfo.tileContext!).updateBuildingInfo(buildingInfo);
          showMessage(context, "Renter has been added successfully");
        } else if(state is AddingRenter){
          showProgressIndicator(context);
        } else if(state is AddRenterError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: apartmentBuildingListener(),
    );
  }

  Widget apartmentBuildingListener(){
    return BlocListener<ApartmentBuildingCubit, ApartmentBuildingState>(
      listener: (context, state) {
        if(state is ApartmentBuildingLoading){
          setState(() {
            _isLoading = true;
          });
        }else if(state is ApartmentBuildingError){
          setState(() {
            _isLoading = true;
          });
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        } else if(state is ApartmentBuildingLoaded){
          setState(() {
            renters =  state.renters;
            hasPrevRenters = state.hasPrevRenters;
            _isLoading = false;
          });
        } else if(state is ApartmentBuildingRentUpdating){
          setState(() {
            buildingInfo.updateBuildingRent(state.rent);
          });
          BlocProvider.of<ApartmentBuildingCubit>(context).updated();
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
                prevRentersItem: _isLoading ? null : previousRentersItem(context, buildingInfo, hasPrevRenters, true, _isLoading),
                propertyDeletionItem: deletePropertyItem(context, buildingInfo.buildingID, _isLoading),
                propertyEditingItem: editPropertyItem(context, buildingInfo, _isLoading),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : renters!.isEmpty
            ? noRenters<ApartmentBuildingCubit>(
                context,
                BlocProvider.of<ApartmentBuildingCubit>(context),
                'None of the rooms in this ${buildingInfo.buildingType} are rented. Please use the + button to add a renter',
                buildingInfo)
            : apartmentRented(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(_isLoading){
              return;
            }
            addRenter(context, buildingInfo.buildingType, buildingInfo.buildingID);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  apartmentRented() {
    return SingleChildScrollView(
      child: Column(
        children: [
          detailRow('Building Name: ${buildingInfo.buildingName}'),
          splitLine(),

          detailRow("Address: ${buildingInfo.buildingAddress}"),
          splitLine(),

          detailRow("Total Annual Rent: ${buildingInfo.buildingRent}"),
          splitLine(),


          detailRow('Renters: '),
          ListView.builder(
            itemCount: renters!.length,
            reverse: true,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, i) {
              List<dynamic> paymentsDynamic = renters![i]['Payments'];

              RenterInfo renterInfo = RenterInfo(
                buildingInfo: buildingInfo,
                renterID: renters![i].id,
                renterName: renters![i]['Name'],
                startDate: DateTime.fromMillisecondsSinceEpoch(renters![i]['StartDate']),
                paymentFrequency: renters![i]['PaymentFrequency'],
                nextPaymentDate: DateTime.fromMillisecondsSinceEpoch(renters![i]['NextPaymentDate']),
                payments: paymentsDynamic.map((element) => int.parse(element)).toList(),
                rent: renters![i]['Rent'],
                apartmentNum: renters![i]['ApartNum'],
                renterNotificationID: buildingInfo.buildingNotificationID + i,
              );

              setNotification(renterInfo);
              return tile(
                renterInfo,
                i % 2,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget tile(RenterInfo renterInfo, int color){
    return ListTile(
      title: Text(renterInfo.renterName, textScaleFactor: 2,),
      subtitle: Text('Apartment #${renterInfo.apartmentNum}', textScaleFactor: 1.3,),
      trailing: Text('${renterInfo.nextPaymentDate.year}/${renterInfo.nextPaymentDate.month}/${renterInfo.nextPaymentDate.day}',textScaleFactor: 1.5,),
      tileColor: renterInfo.nextPaymentDate.isBefore(DateTime.now()) ? Colors.red : color == 1 ? Colors.orangeAccent : Colors.orange,
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteGenerator.renterPage,
          arguments: ApartmentRenterInfo(renterInfo: renterInfo, apartmentBuildingContext: context),
        );
      },
    );
  }
}