import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/database/database.dart';
import 'package:rent/previous_renters/previous_renters_info.dart';
import '../helping_classes/delete_renter/delete_renter_cubit.dart';
import '../helping_classes/help_methods.dart';
import '../helping_classes/pop_up_menu.dart';
import '../helping_classes/renter_info.dart';

class PreviousRentersView extends StatefulWidget {
  final PreviousRentersInfo previousRentersInfo;
  const PreviousRentersView({super.key, required this.previousRentersInfo});

  @override
  State<PreviousRentersView> createState() => _PreviousRentersViewState();
}

class _PreviousRentersViewState extends State<PreviousRentersView> {
  bool _isLoading = true;
  late List<dynamic> renters;
  RenterInfo? selected;

  @override
  void initState() {
    super.initState();
    getPreviousRenters();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if(selected != null){
          setState(() {
            selected = null;
          });
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: renterDeletionListener(),
    );
  }

  Widget renterDeletionListener(){
    return BlocListener<DeleteRenterCubit, DeleteRenterState>(
      listener: (context, state) {
        if(state is DeletedRenter){
          getPreviousRenters();
          Navigator.pop(context);
          selected = null;
          showMessage(context, "Renter Has Been Deleted successfully");
        } else if(state is DeletingRenter){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is DeleteRenterError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: selected != null
          ? page()
          : list(),
    );
  }

  Widget page(){
    return Scaffold(
      appBar: AppBar(
        title: Text(selected!.renterName),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: menu(
              context: context,
              renterRestorationItem: restoreRenterItem(widget.previousRentersInfo.context, selected!, widget.previousRentersInfo.buildingHasSpace),
              renterDeletionItem: deleteRenter(context, selected!),
            ),
          ),
        ],
      ),
      body: renterInfoWidget(selected!),

    );
  }

  Widget list(){
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.previousRentersInfo.buildingInfo.buildingName}\'s Previous Renters'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(),)
          : ListView.builder(
              itemCount: renters.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, i) {
                List<dynamic> paymentsDynamic = renters[i]['Payments'];
                DateTime terminationDate = DateTime.fromMillisecondsSinceEpoch(renters[i]['TerminationDate']);

                RenterInfo renterInfo = RenterInfo(
                  buildingInfo: widget.previousRentersInfo.buildingInfo,
                  renterID: renters[i].id,
                  renterName: renters[i]['Name'],
                  startDate: DateTime.fromMillisecondsSinceEpoch(renters[i]['StartDate']),
                  paymentFrequency: renters[i]['PaymentFrequency'],
                  nextPaymentDate: DateTime.fromMillisecondsSinceEpoch(renters[i]['NextPaymentDate']),
                  payments: paymentsDynamic.map((element) => int.parse(element)).toList(),
                  rent: renters[i]['Rent'],
                  apartmentNum: renters[i]['ApartNum'],
                  terminationDate: terminationDate,
                  renterNotificationID: -1,
                );

                return tile(
                  renterInfo,
                  i % 2,
                  terminationDate,
                );
              },
          ),
    );
  }

  Widget tile(RenterInfo renterInfo, int color, DateTime terminationDate){
    return ListTile(
      title: Text(renterInfo.renterName, textScaleFactor: 2,),
      subtitle: Text(renterInfo.apartmentNum!.isNotEmpty ? 'Apartment #${renterInfo.apartmentNum}' : '', textScaleFactor: 1.3,),
      trailing: Text('${terminationDate.year}/${terminationDate.month}/${terminationDate.day}',textScaleFactor: 1.5,),
      tileColor: color == 1 ? Colors.orangeAccent : Colors.orange,
      onTap: () {
        setState(() {
          selected = renterInfo;
        });
      },
    );
  }

  getPreviousRenters() async {
    final renters = await Database().getPreviousRenters(widget.previousRentersInfo.buildingInfo.buildingID);

    setState(() {
      this.renters = renters;
      _isLoading = false;
    });
  }
}
