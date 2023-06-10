import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rent/database/database.dart';
import 'package:rent/home/tile/renter_tile.dart';
import 'package:rent/routes/route_generator.dart';

import '../helping_classes/notifications.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  Stream? renters;

  @override
  initState() {
    super.initState();
    getRenters();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Renters")),
          automaticallyImplyLeading: false,
        ),
        body: list(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addRenter(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> getRenters() async {
    final renters = await Database().getRenters();

    setState(() {
      this.renters = renters;
    });
  }

  list() {
    return StreamBuilder(
      stream: renters,
      builder: (context, AsyncSnapshot snapshot){
        if (snapshot.hasData){
          if(snapshot.data.docs.isEmpty) {
            return noRenters();
          }
          else{
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              reverse: true,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context,i){
                DateTime time = DateTime.fromMillisecondsSinceEpoch(snapshot.data.docs[i]['NextPaymentDate']);
                DateTime notificationTime = DateTime(time.year, time.month, time.day, 17);
                if(notificationTime.isAfter(DateTime.now())){
                  Notifications().scheduleNotification(
                    id:i,
                    title: 'Rent Collection Date',
                    body: 'Collect Rent from ${snapshot.data.docs[i]['Name']}',
                    date: notificationTime,);
                }
                return RenterTile(id: snapshot.data.docs[i]['Renter_ID'], color: i % 2,);
              },
            );
          }
        }
        else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  addRenter(BuildContext context){
    TextEditingController nameController = TextEditingController();
    TextEditingController startDateController  = TextEditingController();
    TextEditingController rentController  = TextEditingController();
    TextEditingController paymentFrequencyController  = TextEditingController();
    TextEditingController apartNumController  = TextEditingController();
    DateTime? selectedDate;


    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add a Renter"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Renter Name'),
                  ),
                  TextField(
                    controller: apartNumController,
                    decoration: const InputDecoration(labelText: 'Apartment Number'),
                    keyboardType: TextInputType.number,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(), firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                          String month = selectedDate!.month.toString();
                          String day = selectedDate!.day.toString();

                          if(selectedDate!.month < 10){
                            month = '0${selectedDate!.month.toString()}';
                          }

                          if(selectedDate!.day < 10){
                            day = '0${selectedDate!.day.toString()}';
                          }
                          startDateController.text = '${selectedDate!.year.toString()}/$month/$day';
                        });
                      }

                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: startDateController,
                        decoration: const InputDecoration(labelText: 'Start Date'),
                      ),
                    ),
                  ),
                  TextField(
                    controller: rentController,
                    decoration: const InputDecoration(labelText: 'Rent'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: paymentFrequencyController,
                    decoration: const InputDecoration(labelText: 'Payment every X months'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10,),
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
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              startDateController.text.isEmpty ||
                              rentController.text.isEmpty ||
                              paymentFrequencyController.text.isEmpty ||
                              apartNumController.text.isEmpty){
                            showDialog(
                                context: context,
                                builder: (context){
                                  return const AlertDialog(
                                    title: Text("Please Fill all fields"),
                                  );
                                }
                            );
                          }
                          else{
                            Database().addRenter(
                                nameController.text,
                                selectedDate!.millisecondsSinceEpoch,
                                double.parse(rentController.text),
                                int.parse(paymentFrequencyController.text),
                                int.parse(apartNumController.text)
                            );

                            Navigator.pop(context);
                            Navigator.pushNamed(context, RouteGenerator.homePage);

                            showDialog(
                                context: context,
                                builder: (context){
                                  return const AlertDialog(
                                    title: Text("Renter has been added successfully"),
                                  );
                                }
                            );
                          }
                        },
                        child:  const Text("Save"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  noRenters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              addRenter(context);
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
          const Center(
            child: Text(
              "Renters Have not been added yet.\nYou can add Renters from the + button",
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}