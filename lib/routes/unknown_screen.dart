import 'package:flutter/material.dart';
import 'package:rent/database/database.dart';

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Column(
          children: [
            Center(
              child: Text('Oops something went wrong!'),
            ),
          ]
      ),
    );
  }
}