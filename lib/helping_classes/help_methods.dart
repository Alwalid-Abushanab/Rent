import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rent/helping_classes/pay_dialog/pay_dialog.dart';
import 'package:rent/helping_classes/renter_info.dart';
import 'package:rent/home/cubit/home_page_cubit.dart';
import 'package:rent/house/cubit/house_cubit.dart';

import '../apartment_building/cubit/apartment_building_cubit.dart';
import '../database/database.dart';
import 'add_renter/add_renter.dart';
import 'building_info.dart';
import 'notifications.dart';

void showProgressIndicator(BuildContext context){
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(context: context, barrierDismissible: false, builder: (context){
      return const Center(child: CircularProgressIndicator(),);
    });
  });
}

Widget myTextField({
  required TextEditingController controller,
  required String hint,
  required bool obscured,
  String? errorMessage,
  FocusNode? focusNode,
  void Function(String)? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      controller: controller,
      obscureText: obscured,
      focusNode: focusNode,
      onChanged: errorMessage == null ? null : onChanged,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        labelText: hint,
        labelStyle: const TextStyle(fontSize: 20),
        errorText: errorMessage,
      ),
    ),
  );
}

void leaveApp(DateTime? currentBackPressTime, BuildContext context){
  final currentTime = DateTime.now();

  if (currentBackPressTime == null ||
      currentTime.difference(currentBackPressTime) > const Duration(seconds: 2)) {
    currentBackPressTime = currentTime;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Press back again to exit"),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }
  SystemNavigator.pop();
}

void showMessage(BuildContext context, String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  });
}

void addProperty(BuildContext context) {
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String? selectedPropertyType;

  List<String> propertyTypes = ['Office', 'Apartment Building', 'House'];

  BuildContext savedContext = context;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      String? nameErrorText;
      String? locationErrorText;
      String? propertyTypeErrorText;

      void validateFields() {
        nameErrorText = nameController.text.isEmpty ? 'Field is required' : null;
        locationErrorText = locationController.text.isEmpty ? 'Field is required' : null;
        propertyTypeErrorText = selectedPropertyType == null ? 'Field is required' : null;
      }

      void clearErrorText(TextEditingController controller) {
        if (controller.text.isNotEmpty) {
          if (controller == nameController) {
            nameErrorText = null;
          } else if (controller == locationController) {
            locationErrorText = null;
          }
        }
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add a Property"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Property Name',
                      errorText: nameErrorText,
                    ),
                    onChanged: (_) => setState(() => clearErrorText(nameController)),
                  ),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Property Location',
                      errorText: locationErrorText,
                    ),
                    onChanged: (_) => setState(() => clearErrorText(locationController)),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPropertyType,
                    decoration: InputDecoration(
                      labelText: 'Property Type',
                      errorText: propertyTypeErrorText,
                    ),
                    onChanged: (value) => setState(() {
                      selectedPropertyType = value;
                      propertyTypeErrorText = null;
                    }),
                    items: propertyTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          validateFields();
                          if (nameErrorText == null &&
                              locationErrorText == null &&
                              propertyTypeErrorText == null) {
                            BlocProvider.of<HomePageCubit>(savedContext).addProperty(
                              selectedPropertyType!,
                              nameController.text,
                              locationController.text,
                            );
                            Navigator.pop(context);
                          } else {
                            setState(() {}); // Trigger rebuild to show error messages
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget detailRow(String text){
  return Row(
    children: [
      Flexible(
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: text,
            hintStyle: const TextStyle(color: Colors.black, fontSize: 25),
            hintMaxLines: 2,
          ),
        ),
      ),
    ],
  );
}

Widget splitLine(){
  return Container(
    height: 1.0,
    color: Colors.black,
  );
}

Widget noRenters<T extends Cubit>(BuildContext context, T cubit, String message, BuildingInfo buildingInfo) {
  return Column(
    children: [
      detailRow("Building Name: ${buildingInfo.buildingName}"),
      splitLine(),
      const SizedBox(height: 4),

      detailRow("Address: ${buildingInfo.buildingAddress}"),
      splitLine(),
      const SizedBox(height: 4),

      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (BlocProvider.of<T>(context).state is ApartmentBuildingLoading ||
                      BlocProvider.of<T>(context).state is HouseLoading) {
                    return;
                  }
                  addRenter(context, buildingInfo.buildingType, buildingInfo.buildingID);
                },
                child: Icon(
                  Icons.add_circle,
                  color: Colors.grey[700],
                  size: 75,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget payments(RenterInfo renterInfo){
  final Color? grayColor = Colors.grey[200];
  const Color whiteColor = Colors.white;

  return ListView.builder(
    shrinkWrap: true,
    physics: const ClampingScrollPhysics(),
    itemCount: renterInfo.payments.length+1,
    reverse: true,
    itemBuilder: (context, index) {
      int res = renterInfo.payments.length % 2 == 0 ? 0 : 1;
      if(index == renterInfo.payments.length){
        if(renterInfo.terminationDate != null){
          return null;
        }
        return ListTile(
          title: Text("${renterInfo.nextPaymentDate.year}/${renterInfo.nextPaymentDate.month}/${renterInfo.nextPaymentDate.day}", textScaleFactor: 1.3,),
          trailing: ElevatedButton(
              onPressed: (){
                payDialog(context, renterInfo);
              },
              child: const Text("Pay")
          ),
          tileColor: index % 2 == res ? grayColor : whiteColor,
        );
      } else {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(renterInfo.payments[index]);
        return FutureBuilder<String>(
          future: Database().getReceipt(renterInfo.renterID, renterInfo.payments[index], renterInfo.buildingInfo.buildingID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                title: Text("${date.year}/${date.month}/${date.day}", textScaleFactor: 1.3,),
                trailing: const ElevatedButton(
                  onPressed: null,
                  child: Text("Loading..."),
                ),
                tileColor: index % 2 == res ? grayColor : whiteColor,
              );
            } else if (snapshot.hasData) {
              String url = snapshot.data!;
              return ListTile(
                title: Text("${date.year}/${date.month}/${date.day}", textScaleFactor: 1.3,),
                trailing: ElevatedButton(
                  onPressed: url.isNotEmpty ? () async {
                    final status = await Permission.photos.request();

                    if(status.isGranted){
                      final externalDir = await getExternalStorageDirectory();

                      await FlutterDownloader.enqueue(
                          url: url,
                          savedDir: externalDir!.path,
                          openFileFromNotification: true,
                          showNotification: true,
                          saveInPublicStorage: true,
                          fileName: '${renterInfo.buildingInfo.buildingName}_${renterInfo.renterName}\'s_Receipt_${date.year}/${date.month}/${date.day}'
                      );
                    } else{
                      openAppSettings();
                    }
                  } : null,
                  child: const Text("Download receipt"),
                ),
                tileColor: index % 2 == res ? grayColor : whiteColor,
              );
            } else {
              return ListTile(
                title: Text("${date.year}/${date.month}/${date.day}", textScaleFactor: 1.3,),
                trailing: const ElevatedButton(
                  onPressed: null,
                  child: Text("Error"),
                ),
                tileColor: index % 2 == 1 ? Colors.grey[200] : Colors.white,
              );
            }
          },
        );
      }
    },
  );
}

void setNotification(RenterInfo renterInfo){
  DateTime notificationTime = DateTime(
    renterInfo.nextPaymentDate.year,
    renterInfo.nextPaymentDate.month,
    renterInfo.nextPaymentDate.day,
    17,
  );

  if (notificationTime.isAfter(DateTime.now())) {
    Notifications().scheduleNotification(
      id: renterInfo.renterNotificationID,
      title: 'Rent Collection',
      body: 'Collect Rent from ${renterInfo.renterName} in ${renterInfo.buildingInfo.buildingName}',
      date: notificationTime,
    );
  }
}

Widget renterInfoWidget(RenterInfo renterInfo){
  return SingleChildScrollView(
    child: Column(
      children: [
        detailRow("Building Name: ${renterInfo.buildingInfo.buildingName}"),
        splitLine(),

        detailRow("Address: ${renterInfo.buildingInfo.buildingAddress}"),
        splitLine(),

        detailRow("Renter: ${renterInfo.renterName}"),
        splitLine(),

        detailRow("Rent: ${renterInfo.rent} every ${renterInfo.paymentFrequency} months"),
        splitLine(),

        detailRow("Lease Started on: ${renterInfo.startDate.year}/${renterInfo.startDate.month}/${renterInfo.startDate.day}"),
        splitLine(),

        if(renterInfo.terminationDate != null)...[
          detailRow("Lease Terminated on: ${renterInfo.terminationDate!.year}/${renterInfo.terminationDate!.month}/${renterInfo.terminationDate!.day}"),
          splitLine(),
        ],

        detailRow("Payments: "),
        payments(renterInfo),
      ],
    ),
  );
}
