import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../helping_classes/renter_info.dart';

class Database {
  final CollectionReference userRef = FirebaseFirestore.instance.collection("Users");

  createAccount(String email, String name) async {
    return userRef.doc(email).set({
      "Name": name,
      "Email": email,
    });
  }

  addProperty(String propertyType, String propertyName, String propertyAddress) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    var propertiesSnapshot = await userRef.doc(email).collection('Properties').get();
    var deletedPropertiesSnapshot = await userRef.doc(email).collection('DeletedProperties').get();
    var permanentlyDeletedPropertiesSnapshot = await userRef.doc(email).collection('PermanentlyDeletedProperties').get();

    int length = propertiesSnapshot.docs.length + deletedPropertiesSnapshot.docs.length + permanentlyDeletedPropertiesSnapshot.docs.length;

    await userRef.doc(email).collection('Properties').add({
      "PropertyName": propertyName,
      "PropertyAddress": propertyAddress,
      "PropertyType": propertyType,
      'PropertyYearlyRent': 0.00,
      'NotificationID': length * 200,
    });
  }

  updateYearlyRent(String buildingID, double rent) async{
    String email = FirebaseAuth.instance.currentUser!.email!;
    await userRef.doc(email).collection('Properties').doc(buildingID).update({
      'PropertyYearlyRent': rent,
    });
  }

  deleteProperty(String buildingID) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    var documentReference = userRef.doc(email).collection('Properties').doc(buildingID);
    var documentSnapshot = await documentReference.get();
    var documentData = documentSnapshot.data();

    await userRef.doc(email).collection('DeletedProperties').doc(buildingID).set({
      'TerminationDate' : DateTime.now().millisecondsSinceEpoch,
      ...documentData!
    });

    var rentersSubCollection = await documentReference.collection('Renters').get();
    var previousRentersSubCollection = await documentReference.collection('PreviousRenters').get();

    for (var docSnapshot in rentersSubCollection.docs) {
      var documentData = docSnapshot.data();

      await userRef.doc(email).collection('DeletedProperties').doc(buildingID).collection('Renters').add(documentData);
      await docSnapshot.reference.delete();
    }

    for (var docSnapshot in previousRentersSubCollection.docs) {
      var documentData = docSnapshot.data();

      await userRef.doc(email).collection('DeletedProperties').doc(buildingID).collection('PreviousRenters').add(documentData);
      await docSnapshot.reference.delete();
    }


    await documentReference.delete();
  }

  terminateLease(String buildingID, String renterID, double yearlyRent) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    var documentReference = userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters').doc(renterID);
    var documentSnapshot = await documentReference.get();
    var documentData = documentSnapshot.data();

    await userRef.doc(email).collection('Properties').doc(buildingID).collection('PreviousRenters').add({
    'TerminationDate': DateTime.now().millisecondsSinceEpoch,
      ...documentData!,
    });

    await documentReference.delete();

    await userRef.doc(email).collection('Properties').doc(buildingID).update({
      'PropertyYearlyRent' : FieldValue.increment(0-yearlyRent),
    });
  }

  getProperties() async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    final snapshot = await userRef.doc(email).collection('Properties').orderBy('PropertyName', descending: true).get();
    return snapshot.docs;
  }

  getPropertyFromId(String id) async{
    String email = FirebaseAuth.instance.currentUser!.email!;

    return userRef.doc(email).collection('Properties').doc(id).get();
  }

  addRenter(String buildingID, String name, int startDate, double rent, int paymentFrequency, String apartNum,) async{
    String email = FirebaseAuth.instance.currentUser!.email!;

    await userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters').add({
      "Name": name,
      "StartDate": startDate,
      "Rent": rent,
      "PaymentFrequency": paymentFrequency,
      'ApartNum': apartNum,
      'Payments': <int>[],
      'NextPaymentDate': startDate,
    });

    await userRef.doc(email).collection('Properties').doc(buildingID).update({
        'PropertyYearlyRent' : FieldValue.increment(rent* 12/paymentFrequency),
    });
  }

  getRenters(String buildingID) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    final snapshot = await userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters').orderBy('NextPaymentDate', descending: true).get();
    return snapshot.docs;
  }

  getRenterFromID(String renterID, String buildingID) async{
    String email = FirebaseAuth.instance.currentUser!.email!;

    return userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters').doc(renterID).get();
  }


  getName() async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    DocumentSnapshot  documentSnapshot  = await userRef.doc(email).get();

    if(documentSnapshot.exists){
      Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
      String name = data['Name'] as String;
      return name;
    }

    return '';
  }

  saveReceipt(File receipt, RenterInfo renterInfo) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    Reference ref = FirebaseStorage.instance.ref().child('Receipts/$email/${renterInfo.buildingInfo.buildingName}/${renterInfo.renterName}/${renterInfo.renterID}/${receipt.path.split('/').last}');
    UploadTask uploadTask = ref.putFile(receipt);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    Map<String,dynamic> map = {
      "Date" : renterInfo.nextPaymentDate.millisecondsSinceEpoch,
      "URL" : downloadUrl,
    };

    await userRef.doc(email).collection('Properties').doc(renterInfo.buildingInfo.buildingID).collection('Renters').doc(renterInfo.renterID).collection('Receipts').add(map);
  }

  Future<String> getReceipt(String renterID, int date, String buildingID) async{
    String email = FirebaseAuth.instance.currentUser!.email!;

    QuerySnapshot querySnapshot = await userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters')
        .doc(renterID)
        .collection("Receipts")
        .where('Date', isEqualTo: date)
        .get();

    if(querySnapshot.docs.isNotEmpty){
      return querySnapshot.docs.first.get('URL');
    }

    return "";
  }

  addPayment(String renterID, int dateInt, int frequency, String buildingID) async{
    String email = FirebaseAuth.instance.currentUser!.email!;

    DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInt);
    if(date.month+frequency > 12) {
      date = DateTime(date.year+1, (date.month+frequency)%12,date.day);
    } else {
      date = DateTime(date.year, date.month+frequency,date.day);
    }

    await userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters').doc(renterID).update({
      "NextPaymentDate" : date.millisecondsSinceEpoch,
      "Payments" : FieldValue.arrayUnion([dateInt.toString()]),
    });
  }

  getPreviousRenters(String buildingID) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    final snapshot = await userRef.doc(email).collection('Properties').doc(buildingID).collection('PreviousRenters').orderBy('Name',).get();
    return snapshot.docs;
  }

  getPreviousProperties() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    final snapshot = await userRef.doc(email).collection('DeletedProperties').orderBy('PropertyName',).get();
    return snapshot.docs;
  }

  hasPreviousRenters(String buildingID) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    var snapshot = await userRef.doc(email).collection('Properties').doc(buildingID).collection('PreviousRenters').get();
    return snapshot.docs.isNotEmpty;
  }

  hasPreviousProperties() async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    var snapshot = await userRef.doc(email).collection('DeletedProperties').get();
    return snapshot.docs.isNotEmpty;
  }

  updateLease(String buildingID, String renterID, double oldRent, double newRent, int newPaymentFrequency) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    await userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters').doc(renterID).update({
      'Rent': newRent,
      'PaymentFrequency': newPaymentFrequency,
    });

    await userRef.doc(email).collection('Properties').doc(buildingID).update({
      'PropertyYearlyRent': FieldValue.increment((newRent*12/newPaymentFrequency)-oldRent)
    });
  }

  updateProperty(String buildingID, String newName) async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    await userRef.doc(email).collection('Properties').doc(buildingID).update({
      'PropertyName': newName,
    });
  }

  permanentlyDeleteProperty(String buildingID) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    var documentReference = userRef.doc(email).collection('DeletedProperties').doc(buildingID);
    var documentSnapshot = await documentReference.get();
    var documentData = documentSnapshot.data();

    await userRef.doc(email).collection('PermanentlyDeletedProperties').doc(buildingID).set(
      documentData!,
    );

    var rentersSubCollection = await documentReference.collection('Renters').get();
    var previousRentersSubCollection = await documentReference.collection('PreviousRenters').get();

    for (var docSnapshot in rentersSubCollection.docs) {
      var documentData = docSnapshot.data();

      await userRef.doc(email).collection('PermanentlyDeletedProperties').doc(buildingID).collection('Renters').add(documentData);
      await docSnapshot.reference.delete();
    }

    for (var docSnapshot in previousRentersSubCollection.docs) {
      var documentData = docSnapshot.data();

      await userRef.doc(email).collection('PermanentlyDeletedProperties').doc(buildingID).collection('PreviousRenters').add(documentData);
      await docSnapshot.reference.delete();
    }

    await documentReference.delete();
  }

  restoreProperty(String buildingID) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    var documentReference = userRef.doc(email).collection('DeletedProperties').doc(buildingID);
    var documentSnapshot = await documentReference.get();
    var documentData = documentSnapshot.data();

    await userRef.doc(email).collection('Properties').doc(buildingID).set({
      "PropertyName": documentData!['PropertyName'],
      "PropertyAddress": documentData['PropertyAddress'],
      "PropertyType": documentData['PropertyType'],
      'PropertyYearlyRent': documentData['PropertyYearlyRent'],
      'NotificationID': documentData['NotificationID'],
    });

    var rentersSubCollection = await documentReference.collection('Renters').get();
    var previousRentersSubCollection = await documentReference.collection('PreviousRenters').get();

    for (var docSnapshot in rentersSubCollection.docs) {
      var documentData = docSnapshot.data();

      await userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters').add(documentData);
      await docSnapshot.reference.delete();
    }

    for (var docSnapshot in previousRentersSubCollection.docs) {
      var documentData = docSnapshot.data();

      await userRef.doc(email).collection('Properties').doc(buildingID).collection('PreviousRenters').add(documentData);
      await docSnapshot.reference.delete();
    }

    await documentReference.delete();
  }

  restoreRenter(String buildingID, String renterID, double yearlyRent) async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    var documentReference = userRef.doc(email).collection('Properties').doc(buildingID).collection('PreviousRenters').doc(renterID);
    var documentSnapshot = await documentReference.get();
    var documentData = documentSnapshot.data();

    await userRef.doc(email).collection('Properties').doc(buildingID).collection('Renters').add({
      "Name": documentData!['Name'],
      "StartDate": documentData['StartDate'],
      "Rent": documentData['Rent'],
      "PaymentFrequency": documentData['PaymentFrequency'],
      'ApartNum': documentData['ApartNum'],
      'Payments': documentData['Payments'],
      'NextPaymentDate': documentData['NextPaymentDate'],
    });

    await documentReference.delete();

    await userRef.doc(email).collection('Properties').doc(buildingID).update({
      'PropertyYearlyRent' : FieldValue.increment(yearlyRent),
    });
  }

  deleteRenter(String buildingID, String renterID) async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    var documentReference = userRef.doc(email).collection('Properties').doc(buildingID).collection('PreviousRenters').doc(renterID);
    var documentSnapshot = await documentReference.get();
    var documentData = documentSnapshot.data();

    await userRef.doc(email).collection('Properties').doc(buildingID).collection('DeletedRenters').add({
      ...documentData!,
    });

    await documentReference.delete();
  }

  getPreviousBuildingRenters(String buildingID) async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    final renters = await userRef.doc(email).collection('DeletedProperties').doc(buildingID).collection('Renters').orderBy('Name',).get();
    final previousRenters = await userRef.doc(email).collection('DeletedProperties').doc(buildingID).collection('PreviousRenters').orderBy('Name',).get();

    final allRenters = [...renters.docs, ...previousRenters.docs];

    allRenters.sort((a, b) {
      final nameA = a.data()['Name'].toUpperCase();
      final nameB = b.data()['Name'].toUpperCase();

      return nameB.compareTo(nameA);
    });

    return allRenters;
  }
}