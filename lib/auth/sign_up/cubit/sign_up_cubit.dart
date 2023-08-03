import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:rent/database/database.dart';
part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());

  Future<void> trySigningUp(String firstName, String lastName, String email, String password) async {
    emit(SigningUp());

    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      String name = "$firstName $lastName";
      await Database().createAccount(email,name);
      emit(SignedUp());
    } catch (error) {
      if(kDebugMode){
        print(error);
      }

      if(error.toString().contains('network-request-failed')){
        emit(SignUpError());
      } else{
        emit(SignUpFailed());
      }
    }
  }
}
