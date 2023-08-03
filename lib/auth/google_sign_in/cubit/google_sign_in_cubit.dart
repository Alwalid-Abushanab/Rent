import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../database/database.dart';

part 'google_sign_in_state.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  GoogleSignInCubit() : super(GoogleSignInInitial());

  verify() async {
    emit(GoogleLoading());
    try{
      GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(gUser!.email);
      GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      if(signInMethods.isEmpty){
        await Database().createAccount(userCred.user!.email!, userCred.user!.displayName!);
      }

      emit(GoogleLoggedIn());
    } catch(error) {
      emit(GoogleError(message: error.toString()));
    }
  }

  resetState(){
    emit(GoogleSignInInitial());
  }
}
