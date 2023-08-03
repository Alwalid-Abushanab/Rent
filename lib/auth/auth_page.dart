import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/auth/cubit/auth_cubit.dart';
import 'package:rent/auth/google_sign_in/cubit/google_sign_in_cubit.dart';
import 'package:rent/auth/log_in/cubit/log_in_cubit.dart';
import 'package:rent/auth/reset_password/cubit/reset_password_cubit.dart';
import 'package:rent/auth/sign_up/cubit/sign_up_cubit.dart';

import 'auth_view.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(),
          ),
          BlocProvider<GoogleSignInCubit>(
            create: (context) => GoogleSignInCubit(),
          ),
          BlocProvider<LogInCubit>(
            create: (context) => LogInCubit(),
          ),
          BlocProvider<SignUpCubit>(
            create: (context) => SignUpCubit(),
          ),
          BlocProvider<ResetPasswordCubit>(
            create: (context) => ResetPasswordCubit(),
          ),
        ],
        child: const AuthView()
    );
  }
}