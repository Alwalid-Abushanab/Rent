import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'auth_wrapper_state.dart';

class AuthWrapperCubit extends Cubit<AuthWrapperState> {
  AuthWrapperCubit() : super(AuthWrapperInitial()){
    checkStatus();
  }

  void checkStatus(){
    User? currUser = FirebaseAuth.instance.currentUser;

    if(currUser == null){
      emit(AuthWrapperSignedOut());
    } else{
      emit(AuthWrapperSignedIn());
    }
  }

  void signIn(){
    emit(AuthWrapperSignedIn());
  }

  void signOut(){
    emit(AuthWrapperSignedOut());
  }
}
