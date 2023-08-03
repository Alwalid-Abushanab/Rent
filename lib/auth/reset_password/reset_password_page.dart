import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/help_methods.dart';

import 'cubit/reset_password_cubit.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  //email variables
  final emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  String? emailError;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if(state is ResettingPassword){
          showProgressIndicator(context);
        } else if(state is ResetPasswordEmailSent){
          emailController.clear();
          Navigator.pop(context);
          showMessage(context, 'The Password Reset Email Has Been Sent');
        } else if(state is ResetPasswordError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again');
        } else if(state is ResetPasswordFailed){
          Navigator.pop(context);
        }
      },
      child: Center(
        child: SingleChildScrollView(
          child:
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Please Enter your Email.",
                  textScaleFactor: 1.5,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10,),

                BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                  builder: (context, state) {
                    return state is ResetPasswordFailed ? const Text('There is not An Account with this Email', style: TextStyle(color: Colors.red),) : const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 10,),

                //Email Field
                myTextField(
                  controller: emailController,
                  hint: "Email",
                  obscured: false,
                  errorMessage: emailError,
                  focusNode: emailFocusNode,
                  onChanged: (text) => updateEmailError(text),
                ),
                const SizedBox(height: 30,),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      updateEmailError(emailController.text);

                      if (emailError != null) {
                        return;
                      }

                      BlocProvider.of<ResetPasswordCubit>(context)
                          .resetPassword(
                        emailController.text.trim(),
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
                        "Reset Password",
                        textScaleFactor: 1.5,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }

  void emailListener() {
    setState(() {
      if ((emailController.text.isNotEmpty || emailError != null) &&
          !EmailValidator.validate(emailController.text)) {
        emailError = 'Invalid Email Address';
      } else {
        emailError = null;
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
}
