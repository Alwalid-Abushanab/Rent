import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/building_info.dart';
import 'package:rent/helping_classes/permanently_delete_property/permanently_delete_property_cubit.dart';
import 'package:rent/previous_properties/cubit/previous_properties_cubit.dart';
import '../helping_classes/help_methods.dart';
import '../helping_classes/pop_up_menu.dart';
import '../helping_classes/renter_info.dart';

class PreviousPropertiesView extends StatefulWidget {
  final BuildContext homeContext;
  const PreviousPropertiesView({super.key, required this.homeContext});

  @override
  State<PreviousPropertiesView> createState() => _PreviousPropertiesViewState();
}

class _PreviousPropertiesViewState extends State<PreviousPropertiesView> {
  bool _isLoading = true;
  late List<dynamic> properties;
  List<dynamic>? renters;
  BuildingInfo? selectedBuilding;
  RenterInfo? selectedRenter;
  DateTime? terminationDate;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PreviousPropertiesCubit>(context).loadPreviousProperties();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if(selectedRenter != null){
          setState(() {
            selectedRenter = null;
          });
        } else if(selectedBuilding != null){
          setState(() {
            selectedBuilding = null;
            terminationDate = null;
          });
        } else {
          return Future.value(true);
        }
        return Future.value(false);
      },
      child: propertyDeletionListener(),
    );
  }

  Widget propertyDeletionListener(){
    return BlocListener<PermanentlyDeletePropertyCubit, PermanentlyDeletePropertyState>(
      listener: (context, state) {
        if(state is PermanentlyDeletedProperty){
          BlocProvider.of<PreviousPropertiesCubit>(context).loadPreviousProperties();
          Navigator.pop(context);
          selectedBuilding = null;
          showMessage(context, "Property Has Been Deleted successfully");
        } else if(state is PermanentlyDeletingProperty){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is PermanentlyDeletePropertyError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: previousPropertiesListener(),
    );
  }

  Widget previousPropertiesListener(){
    return BlocListener<PreviousPropertiesCubit, PreviousPropertiesState>(
      listener: (context, state) {
        if(state is PreviousPropertiesLoading){
          setState(() {
            _isLoading = true;
          });
        } else if(state is PreviousPropertiesLoaded){
          setState(() {
            properties = state.properties;
            _isLoading = false;
          });
        } else if(state is PreviousPropertiesError){
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        } else if(state is RentersLoaded){
          setState(() {
            renters = state.renters;
            _isLoading = false;
          });
        }
      },
      child: selectedBuilding == null
          ? buildingsList()
          : selectedRenter == null
          ? buildingPage()
          : renterPage(),
    );
  }

  Widget buildingPage(){
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedBuilding!.buildingName),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: menu(
              context: context,
              propertyPermanentDeletionItem: deletePropertyPermanently(context, selectedBuilding!.buildingID),
              propertyRestorationItem: restoreProperty(widget.homeContext, selectedBuilding!.buildingID),
            ),
          ),
        ],
      ),
      body:  _isLoading
          ? const Center(child: CircularProgressIndicator(),)
          : SingleChildScrollView(
              child: Column(
                children: [
                  detailRow('Building Name: ${selectedBuilding!.buildingName}'),
                  splitLine(),

                  detailRow("Address: ${selectedBuilding!.buildingAddress}"),
                  splitLine(),

                  detailRow('Past Renters: '),
                  ListView.builder(
                    itemCount: renters!.length,
                    reverse: true,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, i) {
                      List<dynamic> paymentsDynamic = renters![i]['Payments'];

                      RenterInfo renterInfo;

                      try{
                        renterInfo = RenterInfo(
                          terminationDate: DateTime.fromMillisecondsSinceEpoch(renters![i]['TerminationDate']),
                          buildingInfo: selectedBuilding!,
                          renterID: renters![i].id,
                          renterName: renters![i]['Name'],
                          startDate: DateTime.fromMillisecondsSinceEpoch(renters![i]['StartDate']),
                          paymentFrequency: renters![i]['PaymentFrequency'],
                          nextPaymentDate: DateTime.fromMillisecondsSinceEpoch(renters![i]['NextPaymentDate']),
                          payments: paymentsDynamic.map((element) => int.parse(element)).toList(),
                          rent: renters![i]['Rent'],
                          apartmentNum: renters![i]['ApartNum'],
                          renterNotificationID: selectedBuilding!.buildingNotificationID + i,
                        );
                      } catch (error){
                        renterInfo = RenterInfo(
                          buildingInfo: selectedBuilding!,
                          renterID: renters![i].id,
                          renterName: renters![i]['Name'],
                          startDate: DateTime.fromMillisecondsSinceEpoch(renters![i]['StartDate']),
                          paymentFrequency: renters![i]['PaymentFrequency'],
                          nextPaymentDate: DateTime.fromMillisecondsSinceEpoch(renters![i]['NextPaymentDate']),
                          payments: paymentsDynamic.map((element) => int.parse(element)).toList(),
                          rent: renters![i]['Rent'],
                          apartmentNum: renters![i]['ApartNum'],
                          renterNotificationID: selectedBuilding!.buildingNotificationID + i,
                          terminationDate: terminationDate,
                        );
                      }

                      return renterTile(
                        renterInfo,
                        i % 2,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget renterPage(){
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedRenter!.renterName),
        centerTitle: true,
      ),
      body: renterInfoWidget(selectedRenter!),

    );
  }

  Widget renterTile(RenterInfo renterInfo, int color){
    return ListTile(
      title: Text(renterInfo.renterName, textScaleFactor: 2,),
      subtitle: renterInfo.apartmentNum!.isEmpty ?  null : Text('Apartment #${renterInfo.apartmentNum}', textScaleFactor: 1.3,),
      tileColor: color == 1 ? Colors.orangeAccent : Colors.orange,
      onTap: () {
        setState(() {
          selectedRenter = renterInfo;
        });
      },
    );
  }

  Widget buildingsList(){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Properties'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(),)
          : ListView.builder(
            itemCount: properties.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, i) {
              BuildingInfo buildingInfo = BuildingInfo(
                  buildingID: properties[i].id,
                  buildingName: properties[i]['PropertyName'],
                  buildingAddress: properties[i]['PropertyAddress'],
                  buildingType: properties[i]['PropertyType'],
                  buildingRent: properties[i]['PropertyYearlyRent'],
                  buildingNotificationID: properties[i]['NotificationID'],
              );

              return buildingTile(
                buildingInfo,
                i % 2,
                DateTime.fromMillisecondsSinceEpoch(properties[i]['TerminationDate']),
              );
            },
          ),
    );
  }

  Widget buildingTile(BuildingInfo buildingInfo, int color, DateTime terminationDate){
    return ListTile(
        leading: Icon(
            buildingInfo.buildingType == 'Office'
            ? Icons.business
            : buildingInfo.buildingType == 'House'
            ? Icons.house
            : Icons.apartment,
          color: Colors.white,
          size: 50,
        ),
      title: Text(buildingInfo.buildingName, textScaleFactor: 2,),
      subtitle: Text(buildingInfo.buildingAddress, textScaleFactor: 1.3,),
      tileColor: color == 1 ? Colors.orangeAccent : Colors.orange,
      onTap: () {
        setState(() {
          selectedBuilding = buildingInfo;
          this.terminationDate = terminationDate;
        });
        BlocProvider.of<PreviousPropertiesCubit>(context).loadRenters(buildingInfo.buildingID);
      },
    );
  }
}
