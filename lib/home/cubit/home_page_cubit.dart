import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../database/database.dart';

part 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit() : super(HomePageInitial());

  Future<void> addProperty(String propertyType, String propertyName, String propertyAddress) async {
    emit(HomePageLoading());
    try{
      await Database().addProperty(
        propertyType,
        propertyName,
        propertyAddress,
      );

      emit(PropertyAdded());
      loadData();
    } catch (error){
      emit(HomePageError());
    }
  }

  Future<void> loadData()async {
    emit(HomePageLoading());
    try{
      final properties = await Database().getProperties();
      String userName = await Database().getName();
      String userEmail = FirebaseAuth.instance.currentUser!.email!;
      final hasPrevProperties = await Database().hasPreviousProperties();

      double totalAnnualRent = 0;
      for(int i = 0; i < properties.length; i++){
        totalAnnualRent += properties[i]['PropertyYearlyRent'];
      }

      emit(HomePageData(properties: properties, name: userName, email: userEmail, hasPrevProperties: hasPrevProperties, totalAnnualRent: totalAnnualRent));
    } catch (error){
      emit(HomePageError());
    }
  }
}
