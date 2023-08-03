import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/auth/auth_page.dart';
import '../home/home_page.dart';
import 'cubit/auth_wrapper_cubit.dart';

class AuthWrapperView extends StatefulWidget{
  const AuthWrapperView({super.key});

  @override
  State<AuthWrapperView> createState() => _AuthWrapperViewState();
}

class _AuthWrapperViewState extends State<AuthWrapperView> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthWrapperCubit, AuthWrapperState>(
        builder: (context, state) {
          if (state is AuthWrapperSignedIn) {
            return const HomePage();
          } else {
            return const AuthPage();
          }
        },
    );
  }
}