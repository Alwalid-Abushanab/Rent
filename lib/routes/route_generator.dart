import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rent/routes/unknown_screen.dart';
import '../home/home_page.dart';
import '../renters/renter_page.dart';

class RouteGenerator {
  static const String homePage = '/';
  static const String renterPage = '/renterPage';

  //private constructor
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case renterPage:
        String id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => RenterPage(id: id),
        );

    }
    if (kDebugMode) {
      return MaterialPageRoute(builder: (context) => UnknownScreen());
    } else {
      return MaterialPageRoute(builder: (context) => const HomePage());
    }
  }
}