import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import '../../auth_wrapper/cubit/auth_wrapper_cubit.dart';
import '../../helping_classes/help_methods.dart';
import 'cubit/google_sign_in_cubit.dart';


class GoogleSignInButton {
  Widget googleButton(BuildContext context){
    return BlocBuilder<GoogleSignInCubit, GoogleSignInState>(
        builder: (context, state) {
          if(state is GoogleLoading){
            showProgressIndicator(context);
          } else if(state is GoogleError){
            Navigator.pop(context);
            showMessage(context, 'Please Check Your Internet Connection And Try Again');
          } else if(state is GoogleLoggedIn){
            Navigator.pop(context);
            BlocProvider.of<AuthWrapperCubit>(context).signIn();
          }

          return SignInButton(
            Buttons.GoogleDark,
            onPressed: () {
              FocusScope.of(context).unfocus();
              BlocProvider.of<GoogleSignInCubit>(context).verify();
            },
          );
        },
    );
  }
}