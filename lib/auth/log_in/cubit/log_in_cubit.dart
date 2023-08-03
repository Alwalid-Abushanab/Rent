import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
part 'log_in_state.dart';

class LogInCubit extends Cubit<LogInState> {
  LogInCubit() : super(LogInInitial());


  Future<void> tryLoggingIn(String email, String password) async {
    emit(LoggingIn());

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      emit(LoggedIn());
    } catch(error) {
      if(kDebugMode){
        print(error);
      }

      if(error.toString().contains('network-request-failed')){
        emit(LogInError());
      } else{
        emit(LogInFailed());
      }
    }
  }
}
