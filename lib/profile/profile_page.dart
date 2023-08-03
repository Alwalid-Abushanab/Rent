import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent/helping_classes/help_methods.dart';
import 'package:rent/routes/route_generator.dart';

class ProfilePage extends StatefulWidget{
  final String name;
  final String email;
  final bool hasPrevProperties;
  final double totalAnnualRent;

  const ProfilePage({super.key, required this.name, required this.email, required this.hasPrevProperties, required this.totalAnnualRent});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        detailRow('Name: ${widget.name}'),
        splitLine(),

        detailRow('Email: ${widget.email}'),
        splitLine(),

        detailRow('Total Annual Rent : ${widget.totalAnnualRent.toStringAsFixed(2)}'),
        splitLine(),
        const SizedBox(height: 50),

        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, RouteGenerator.previousPropertiesPage, arguments: context);
          },
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Deleted Properties', textScaleFactor: 1.5,),
          ),
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamed(context, RouteGenerator.authenticationPage);
          },
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Sign Out', textScaleFactor: 1.5,),
          ),
        ),
      ],
    );
  }
}