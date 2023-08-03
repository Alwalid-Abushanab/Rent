import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rent/apartment_building/apartment_building_page.dart';
import 'package:rent/apartment_building/renter/apt_renter_info.dart';
import 'package:rent/house/house_page.dart';
import 'package:rent/previous_properties/previous_properties_page.dart';
import 'package:rent/previous_renters/previous_renters_info.dart';
import 'package:rent/routes/unknown_screen.dart';
import '../apartment_building/renter/renter_page.dart';
import '../auth/reset_password/reset_password_page.dart';
import '../auth_wrapper/auth_wrapper_page.dart';
import '../helping_classes/building_info.dart';
import '../home/home_page.dart';
import '../previous_renters/previous_renters_page.dart';

class RouteGenerator {
  static const String authenticationPage = '/';
  static const String renterPage = '/RenterPage';
  static const String apartmentBuildingPage = '/ApartmentBuildingPage';
  static const String homePage = '/homePage';
  static const String logInPage = '/LogInPage';
  static const String signUpPage = '/SignUpPage';
  static const String resetPasswordPage = '/ResetPasswordPage';
  static const String profilePage = '/ProfilePage';
  static const String housePage = '/HousePage';
  static const String previousRentersPage = '/PreviousRentersList';
  static const String previousPropertiesPage = '/PreviousPropertiesPage';

  //private constructor
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authenticationPage:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapperPage(),
        );
      case homePage:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case renterPage:
        ApartmentRenterInfo aptRenterInfo = settings.arguments as ApartmentRenterInfo;
        return MaterialPageRoute(
          builder: (_) => RenterPage(apartmentRenterInfo: aptRenterInfo),
        );
      case apartmentBuildingPage:
        BuildingInfo buildingInfo = settings.arguments as BuildingInfo;
        return MaterialPageRoute(
          builder: (_) => ApartmentBuildingPage(buildingInfo: buildingInfo),
        );
      case resetPasswordPage:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordPage(),
        );
      case housePage:
        BuildingInfo buildingInfo = settings.arguments as BuildingInfo;
        return MaterialPageRoute(
          builder: (_) => HousePage(buildingInfo: buildingInfo),
        );
      case previousRentersPage:
        PreviousRentersInfo buildingContext = settings.arguments as PreviousRentersInfo;
        return MaterialPageRoute(
          builder: (_) => PreviousRentersPage(previousRentersInfo: buildingContext),
        );
      case previousPropertiesPage:
        final BuildContext homeContext = settings.arguments as BuildContext;
        return MaterialPageRoute(
          builder: (_) => PreviousPropertiesPage(homeContext: homeContext,),
        );
    }

    if (kDebugMode) {
      return MaterialPageRoute(builder: (context) => const UnknownScreen());
    } else {
      return MaterialPageRoute(builder: (context) => const HomePage());
    }
  }
}