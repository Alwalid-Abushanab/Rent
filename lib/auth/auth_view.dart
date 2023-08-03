import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/auth/cubit/auth_cubit.dart';
import 'package:rent/auth/log_in/log_in_page.dart';
import 'package:rent/auth/reset_password/reset_password_page.dart';
import 'package:rent/auth/sign_up/signup_page.dart';
import '../helping_classes/help_methods.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late int _pageIndex;
  DateTime? _currentBackPressTime;

  static const List<Widget> _pages = <Widget>[
    LogInPage(),
    SignUpPage(),
    ResetPasswordPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_pageIndex != 0) {
          setState(() {
            _pageIndex = 0;
          });
          return Future.value(false);
        }
        leaveApp(_currentBackPressTime, context);
        _currentBackPressTime = DateTime.now();
        return Future.value(false);
      },
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if(state is AuthSignUp){
            setState(() {
              _pageIndex = 1;
            });
          } else if(state is AuthResetPassword){
            setState(() {
              _pageIndex = 2;
            });
          } else {
            if(state is AuthError){
              showMessage(context, 'An Error Occurred, Please Try Again');
            }

            setState(() {
              _pageIndex = 0;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_pageIndex == 0 ? 'Login' : _pageIndex == 1 ? 'Sign Up' : 'Reset Password'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: _pages.elementAt(_pageIndex),
        ),
      ),
    );
  }
}