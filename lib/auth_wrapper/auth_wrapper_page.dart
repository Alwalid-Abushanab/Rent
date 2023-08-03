import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_wrapper_view.dart';
import 'cubit/auth_wrapper_cubit.dart';

class AuthWrapperPage extends StatelessWidget {
  const AuthWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthWrapperCubit>(
            create: (context) => AuthWrapperCubit(),
          ),
        ],
        child: const AuthWrapperView()
    );
  }
}