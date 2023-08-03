import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/restore_property/restore_property_cubit.dart';
import 'package:rent/home/cubit/home_page_cubit.dart';
import 'package:rent/home/home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HomePageCubit>(
            create: (context) => HomePageCubit(),
          ),
          BlocProvider<RestorePropertyCubit>(
            create: (context) => RestorePropertyCubit(),
          ),
        ],
        child: const HomeView()
    );
  }
}