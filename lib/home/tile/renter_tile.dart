import 'package:flutter/material.dart';
import 'package:rent/routes/route_generator.dart';
import '../../database/database.dart';

class RenterTile extends StatefulWidget {
  final String id;
  final int color;
  const RenterTile({super.key, required this.id, required this.color});

  @override
  State<RenterTile> createState() => _RenterTileState();
}

class _RenterTileState extends State<RenterTile>{
  bool _isLoading = true;
  String name = "";
  int paymentFrequency = 0;
  int apartNum = 0;
  late DateTime nextPaymentDate;


  @override
  initState() {
    super.initState();
    getRenterData();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ?
        const Center(child: CircularProgressIndicator(),) :
        ListTile(
          title: Text(name, textScaleFactor: 2,),
          subtitle: Text('Apartment #$apartNum', textScaleFactor: 1.3,),
          trailing: Text('${nextPaymentDate.year}/${nextPaymentDate.month}/${nextPaymentDate.day}',textScaleFactor: 1.5,),
          tileColor: nextPaymentDate.isBefore(DateTime.now()) ? Colors.red : widget.color == 1 ? Colors.orangeAccent : Colors.orange,
          onTap: () {
            Navigator.pushNamed(context, RouteGenerator.renterPage, arguments: widget.id);
          },
        );
  }

  Future<void> getRenterData() async {
    final snapshot = await Database().getRenterFromID(widget.id).get();
    int nextPayment = snapshot.docs.first.get('NextPaymentDate');


    setState(() {
      name = snapshot.docs.first.get('Name');
      apartNum = snapshot.docs.first.get('ApartNum');
      nextPaymentDate = DateTime.fromMillisecondsSinceEpoch(nextPayment);
      _isLoading = false;
    });
  }
}