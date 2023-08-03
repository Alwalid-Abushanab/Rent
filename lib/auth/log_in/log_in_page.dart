import 'package:email_validator/email_validator.dart';
import 'package:rent/auth/cubit/auth_cubit.dart';
import '../../auth_wrapper/cubit/auth_wrapper_cubit.dart';
import '../../helping_classes/help_methods.dart';
import '../../routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../google_sign_in/google_sign_in.dart';
import 'cubit/log_in_cubit.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  //email variables
  final emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  String? emailError;

  //password variables
  final passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  String? passwordError;


  DateTime? _currentBackPressTime;

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(emailListener);
    passwordFocusNode.addListener(passwordListener);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        leaveApp(_currentBackPressTime, context);
        _currentBackPressTime = DateTime.now();
        return Future.value(false);
      },
      child: BlocListener<LogInCubit, LogInState>(
        listener: (context, state) {
          if (state is LogInFailed) {
            Navigator.pop(context);
            passwordController.clear();
          } else if (state is LoggingIn) {
            showProgressIndicator(context);
          } else if(state is LogInError){
            Navigator.pop(context);
            passwordController.clear();
            showMessage(context, 'Please Check Your Internet Connection And Try Again');
          } else if(state is LoggedIn){
            Navigator.pop(context);
            BlocProvider.of<AuthWrapperCubit>(context).signIn();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Please login to continue", textScaleFactor: 1.5,),
                const SizedBox(height: 15,),
                BlocBuilder<LogInCubit, LogInState>(
                  builder: (context, state) {
                    return state is LogInFailed ? const Text('Incorrect Email Or Password', style: TextStyle(color: Colors.red),) : const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 15,),

                //Email Field
                myTextField(
                  controller: emailController,
                  hint: "Email",
                  obscured: false,
                  errorMessage: emailError,
                  focusNode: emailFocusNode,
                  onChanged: (text) => updateEmailError(text),
                ),
                const SizedBox(height: 15,),

                //password field
                myTextField(
                  controller: passwordController,
                  hint: 'Password',
                  obscured: true,
                  errorMessage: passwordError,
                  focusNode: passwordFocusNode,
                  onChanged: (text) => updatePasswordError(text),
                ),
                const SizedBox(height: 10,),

                //forgot Password field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          BlocProvider.of<AuthCubit>(context).changeScreen(AuthCubit.resetPasswordScreen);
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),

                //log in button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      updateEmailError(emailController.text);
                      updatePasswordError(passwordController.text);

                      if (passwordError != null || emailError != null) {
                        return;
                      }

                      BlocProvider.of<LogInCubit>(context).tryLoggingIn(
                        emailController.text,
                        passwordController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Sign in",
                        textScaleFactor: 1.5,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),

                //google login
                GoogleSignInButton().googleButton(context),
                const SizedBox(height: 50,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(width: 5,),
                    GestureDetector(
                      onTap: () => BlocProvider.of<AuthCubit>(context).changeScreen(AuthCubit.signUpScreen),
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateEmailError(String text) {
    setState(() {
      if (!EmailValidator.validate(text)) {
        emailError = 'Invalid Email Address';
      } else {
        emailError = null;
      }
    });
  }

  void updatePasswordError(String text) {
    setState(() {
      if (text.length < 6) {
        passwordError = 'Password must be at least 6 characters long';
      } else {
        passwordError = null;
      }
    });
  }

  void emailListener() {
    setState(() {
      if ((emailController.text.isNotEmpty || emailError != null) && !EmailValidator.validate(emailController.text)) {
        emailError = 'Invalid Email Address';
      } else {
        emailError = null;
      }
    });
  }

  void passwordListener() {
    setState(() {
      if ((passwordController.text.isNotEmpty || passwordError != null) && passwordController.text.length < 6) {
        passwordError = 'Password must be at least 6 characters long';
      } else {
        passwordError = null;
      }
    });
  }
}

