import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/permanently_delete_property/permanently_delete_property_cubit.dart';
import 'package:rent/previous_properties/previous_properties_view.dart';

import 'cubit/previous_properties_cubit.dart';

class PreviousPropertiesPage extends StatelessWidget {
  final BuildContext homeContext;
  const PreviousPropertiesPage({super.key, required this.homeContext});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<PermanentlyDeletePropertyCubit>(
            create: (context) => PermanentlyDeletePropertyCubit(),
          ),
          BlocProvider<PreviousPropertiesCubit>(
            create: (context) => PreviousPropertiesCubit(),
          ),
        ],
        child: PreviousPropertiesView(homeContext: homeContext),
    );
  }
}