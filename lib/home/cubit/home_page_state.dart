part of 'home_page_cubit.dart';

@immutable
abstract class HomePageState {}

class HomePageInitial extends HomePageState {}

class HomePageLoading extends HomePageState {}

class HomePageError extends HomePageState {}

class HomePageData extends HomePageState {
  final List<dynamic> properties;
  final String name;
  final String email;
  final bool hasPrevProperties;
  final double totalAnnualRent;

  HomePageData({required this.properties, required this.name, required this.email, required this.hasPrevProperties, required this.totalAnnualRent});
}

class PropertyAdded extends HomePageState {}

