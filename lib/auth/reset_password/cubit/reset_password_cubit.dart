import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordInitial());

  Future<void> resetPassword(String email) async {
    emit(ResettingPassword());

    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: email
      );

      emit(ResetPasswordEmailSent());
    } catch (error) {
      if(kDebugMode){
        print(error);
      }

      if(error.toString().contains('user-not-found')){
        emit(ResetPasswordFailed());
      } else{
        emit(ResetPasswordError());
      }
    }
  }
}
