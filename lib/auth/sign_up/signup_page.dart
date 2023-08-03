import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth_wrapper/cubit/auth_wrapper_cubit.dart';
import '../../helping_classes/help_methods.dart';
import '../../routes/route_generator.dart';
import '../cubit/auth_cubit.dart';
import '../google_sign_in/google_sign_in.dart';
import 'cubit/sign_up_cubit.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //first name variables
  final firstNameController = TextEditingController();
  String? firstNameError;

  //last name variables
  final lastNameController = TextEditingController();
  String? lastNameError;

  //email variables
  final emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  String? emailError;

  //password variables
  final passwordController = TextEditingController();
  late final FocusNode passwordFocusNode = FocusNode();
  String? passwordError;

  //confirm password variables
  final confirmPasswordController = TextEditingController();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  String? confirmPasswordError;

  String? error;


  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(emailListener);
    passwordFocusNode.addListener(passwordListener);
    confirmPasswordFocusNode.addListener(confirmPasswordListener);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpFailed) {
            Navigator.pop(context);
            passwordController.clear();
            confirmPasswordController.clear();
          } else if (state is SigningUp) {
            showProgressIndicator(context);
          } else if(state is SignedUp){
            Navigator.pop(context);
            BlocProvider.of<AuthWrapperCubit>(context).signIn();
            Navigator.pop(context);
          } else if(state is SignUpError){
            Navigator.pop(context);
            passwordController.clear();
            confirmPasswordController.clear();
            showMessage(context, 'Please Check Your Internet Connection And Try Again');
          }
        },
      child: Center(
        child: SingleChildScrollView(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Please Fill the following fields to Sign Up",textScaleFactor: 1.5,),
              const SizedBox(height: 15,),

              BlocBuilder<SignUpCubit, SignUpState>(
                builder: (context, state) {
                  return state is SignUpFailed ? const Text('There is an account with this Email', style: TextStyle(color: Colors.red),) : const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 15,),

              //firstName Field
              myTextField(
                controller: firstNameController,
                hint: "First Name",
                obscured: false,
                errorMessage: firstNameError,
                onChanged: (text) => updateFirstNameError(text),
              ),
              const SizedBox(height: 15,),

              //lastName Field
              myTextField(
                controller: lastNameController,
                hint: "Last Name",
                obscured: false,
                errorMessage: lastNameError,
                onChanged: (text) => updateLastNameError(text),
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
              const SizedBox(height: 15,),

              //confirm password
              myTextField(
                controller: confirmPasswordController,
                hint: 'Confirm Password',
                obscured: true,
                errorMessage: confirmPasswordError,
                focusNode: confirmPasswordFocusNode,
                onChanged: (text) => updateConfirmPasswordError(text),
              ),
              const SizedBox(height: 20,),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    updateFirstNameError(firstNameController.text);
                    updateLastNameError(lastNameController.text);
                    updateEmailError(emailController.text);
                    updatePasswordError(passwordController.text);
                    updateConfirmPasswordError(confirmPasswordController.text);

                    if(firstNameError != null ||
                        lastNameError != null ||
                        emailError != null ||
                        passwordError != null ||
                        confirmPasswordError != null){
                      return;
                    }

                    if (passwordController.text != confirmPasswordController.text) {
                      setState(() {
                        confirmPasswordError = 'Password and Confirm Password Must match';
                      });
                      return;
                    }

                    BlocProvider.of<SignUpCubit>(context).trySigningUp(
                      firstNameController.text,
                      lastNameController.text,
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
                      "Sign up",
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
                  const Text('Already a member?'),
                  const SizedBox(width: 5,),
                  GestureDetector(
                    onTap: () => BlocProvider.of<AuthCubit>(context).changeScreen(AuthCubit.logInScreen),
                    child: const Text('Login Now',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void updateFirstNameError(String text) {
    setState(() {
      if (text.isEmpty) {
        firstNameError = 'Please Enter Your First Name';
      } else {
        firstNameError = null;
      }
    });
  }

  void updateLastNameError(String text) {
    setState(() {
      if (text.isEmpty) {
        lastNameError = 'Please Enter Your Last Name';
      } else {
        lastNameError = null;
      }
    });
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

  void updateConfirmPasswordError(String text) {
    setState(() {
      if (text.length < 6) {
        confirmPasswordError = 'Password must be at least 6 characters long';
      } else {
        confirmPasswordError = null;
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

  void confirmPasswordListener() {
    setState(() {
      if ((confirmPasswordController.text.isNotEmpty || confirmPasswordError != null) && confirmPasswordController.text.length < 6) {
        confirmPasswordError = 'Password must be at least 6 characters long';
      } else {
        confirmPasswordError = null;
      }
    });
  }
}
