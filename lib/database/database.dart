import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../helping_classes/renter_info.dart';

class Database {
  final CollectionReference eventRef = FirebaseFirestore.instance.collection("events");
  final CollectionReference rentersRef = FirebaseFirestore.instance.collection("renters");

  addRenter(String name, int startDate, double rent, int paymentFrequency, int apartNum) async{
    DocumentReference dr = await rentersRef.add({
      "Renter_ID": "",
      "Name": name,
      "StartDate": startDate,
      "Rent": rent,
      "PaymentFrequency": paymentFrequency,
      'ApartNum': apartNum,
      'Payments': <int>[],
      'NextPaymentDate': startDate,
    });

    await dr.update({
      "Renter_ID": dr.id,
    });
  }

  getRenters() async {
    return rentersRef.orderBy('NextPaymentDate', descending: true).snapshots();
  }

  getRenterFromID(String id){
    return rentersRef.where("Renter_ID", isEqualTo: id);
  }

  saveReceipt(File receipt,String name, int date, String id) async {
    Reference ref = FirebaseStorage.instance.ref().child('Receipts/$name/${receipt.path.split('/').last}');
    UploadTask uploadTask = ref.putFile(receipt);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    Map<String,dynamic> map = {
      "Date" : date,
      "URL" : downloadUrl,
    };

    await rentersRef.doc(id).collection("Receipts").add(map);
  }

  Future<String> getReceipt(String id, int date) async{
    QuerySnapshot querySnapshot = await rentersRef
        .doc(id)
        .collection("Receipts")
        .where('Date', isEqualTo: date)
        .get();

    if(querySnapshot.docs.isNotEmpty){
      return querySnapshot.docs.first.get('URL');
    }

    return "";
  }

  addPayment(String id, int dateInt, int frequency) async{
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInt);
    if(date.month+frequency > 12){
      date = DateTime(date.year+1, (date.month+frequency)%12,date.day);
    }else{
      date = DateTime(date.year, date.month+frequency,date.day);
    }
    rentersRef.doc(id).update({
      "NextPaymentDate" : date.millisecondsSinceEpoch,
      "Payments" : FieldValue.arrayUnion([dateInt.toString()]),
    });
  }
}