import 'dart:isolate';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rent/routes/route_generator.dart';
import 'dart:io';

import '../database/database.dart';
import '../helping_classes/notifications.dart';

class RenterPage extends StatefulWidget{
  final String id;
  const RenterPage({super.key, required this.id});

  @override
  State<RenterPage> createState() => _RenterPageState();
}

class _RenterPageState extends State<RenterPage>{
  bool _isLoading = true;

  String name = "";
  int paymentFrequency = 0;
  int apartNum = 0;
  double rent = 0;
  late DateTime nextPaymentDate;
  late DateTime startDate;
  List<int> payments = [];

  final ReceivePort _port = ReceivePort();

  @override
  initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
    getRenterData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isLoading ? "Loading" : name),
      ),
      body: _isLoading ?
      const Center(child: CircularProgressIndicator(),) :
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Flexible(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Name: $name",
                      hintStyle: const TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 1.0,
              color: Colors.black, // Color for the line
            ),
            const SizedBox(height: 4,),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Apartment #$apartNum",
                      hintStyle: const TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Rent: $rent",
                      hintStyle: const TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 1.0,
              color: Colors.black, // Color for the line
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Lease Started On: ${startDate.year}/${startDate.month}/${startDate.day}",
                      hintStyle: const TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 1.0,
              color: Colors.black, // Color for the line
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Rent is Paid Every $paymentFrequency months",
                      hintStyle: const TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 1.0,
              color: Colors.black, // Color for the line
            ),
            const Row(
              children: [
                Flexible(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Payments: ",
                      hintStyle: TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: payments.length+1,
              reverse: true,
              itemBuilder: (context, index) {
                if(index == payments.length){
                  return ListTile(
                    title: Text("${nextPaymentDate.year}/${nextPaymentDate.month}/${nextPaymentDate.day}", textScaleFactor: 1.3,),
                    trailing: ElevatedButton(
                        onPressed: (){
                          payDialog(context);
                        },
                        child: const Text("Pay")
                    ),
                    tileColor: Colors.grey[200],
                  );
                }else {
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(payments[index]);
                  return FutureBuilder<String>(
                    future: Database().getReceipt(widget.id, payments[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text("${date.year}/${date.month}/${date.day}", textScaleFactor: 1.3,),
                          trailing: const ElevatedButton(
                            onPressed: null,
                            child: Text("Loading..."),
                          ),
                          tileColor: index % 2 == 1 ? Colors.grey[200] : Colors.white,
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
                                  fileName: '$name\'s_Receipt_${date.year}/${date.month}/${date.day}'
                                );
                              }else{
                                openAppSettings();
                              }
                            } : null,
                            child: const Text("Download receipt"),
                          ),
                          tileColor: index % 2 == 1 ? Colors.grey[200] : Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getRenterData() async {
    final snapshot = await Database().getRenterFromID(widget.id).get();
    int nextPayment = snapshot.docs.first.get('NextPaymentDate');
    List<dynamic> paymentsDynamic = snapshot.docs.first.get('Payments');

    setState(() {
      name = snapshot.docs.first.get('Name');
      apartNum = snapshot.docs.first.get('ApartNum');
      rent = snapshot.docs.first.get('Rent');
      startDate= DateTime.fromMillisecondsSinceEpoch(snapshot.docs.first.get('StartDate'));
      paymentFrequency = snapshot.docs.first.get('PaymentFrequency');
      payments = paymentsDynamic.map((element) => int.parse(element)).toList();
      nextPaymentDate = DateTime.fromMillisecondsSinceEpoch(nextPayment);
      _isLoading = false;
    });
  }

  payDialog(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            title: Text("Are you sure You want to mark the payment on "
                "${nextPaymentDate.year}/${nextPaymentDate.month}/${nextPaymentDate.day}"
                " for $name in Apartment #$apartNum as paid?"
                " (The Payment Should be $rent\$)"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No")
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context){
                          return AlertDialog(
                            title: const Text("Do you Want to Add A picture of the Receipt"),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    changeNextPaymentDate();
                                    Navigator.pop(context);
                                  },
                                  child: const Text("No")
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    final result = await FilePicker.platform.pickFiles(
                                        allowMultiple: false,
                                        type: FileType.custom,
                                        allowedExtensions: ['png','jpg']);
                                    if (result == null){
                                      Navigator.pop(context);
                                      return showDialog(context: context, builder: (context){
                                        return const AlertDialog(
                                          title: Text('No File was selected'),
                                        );
                                      });
                                    }
                                    else if(result.files.single.extension! != 'png' && result.files.single.extension! != 'jpg'){
                                      return showDialog(context: context, builder: (context){
                                        return const AlertDialog(
                                          title: Text('Invalid File type, You can only share pictures of type png or jpg'),
                                        );
                                      });
                                    }
                                    else{
                                      final file = File(result.files.single.path!);
                                      showDialog(context: context,barrierDismissible: false, builder: (context){
                                        return const AlertDialog(
                                          title: CircularProgressIndicator(),
                                        );
                                      });
                                      await Database().saveReceipt(file,name,nextPaymentDate.millisecondsSinceEpoch, widget.id);
                                      changeNextPaymentDate();

                                      return showDialog(context: context, builder: (context){
                                        return const AlertDialog(
                                          title: Text('Receipt Has been saved'),
                                        );
                                      });
                                    }
                                  },
                                  child: const Text("Yes")
                              ),
                            ],
                          );
                        }
                    );
                  },
                  child: const Text("Yes")
              ),
            ],
          );
        }
    );
  }

  changeNextPaymentDate() async{
    await Database().addPayment(widget.id, nextPaymentDate.millisecondsSinceEpoch, paymentFrequency);
    Navigator.pushNamed(context, RouteGenerator.homePage);
    Navigator.pushNamed(context, RouteGenerator.renterPage, arguments: widget.id);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }
}