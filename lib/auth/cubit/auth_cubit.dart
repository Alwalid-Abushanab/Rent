import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  static const int logInScreen = 0;
  static const int signUpScreen = 1;
  static const int resetPasswordScreen = 2;

  AuthCubit() : super(AuthInitial()){
    changeScreen(logInScreen);
  }

  void changeScreen(int selectedScreen){
    if(selectedScreen == logInScreen){
      emit(AuthLogIn());
    } else if(selectedScreen == signUpScreen){
      emit(AuthSignUp());
    } else if(selectedScreen == resetPasswordScreen) {
      emit(AuthResetPassword());
    } else {
      emit(AuthError());
    }
  }
}
