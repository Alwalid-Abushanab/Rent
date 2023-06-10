import 'package:flutter/material.dart';
import 'package:rent/routes/route_generator.dart';

class RentApp extends MaterialApp {
  RentApp({Key? key}) : super(key: key,
    initialRoute:  RouteGenerator.homePage,
    onGenerateRoute: RouteGenerator.generateRoute,
    theme: ThemeData(
      primarySwatch: Colors.cyan,
    ),
  );
}