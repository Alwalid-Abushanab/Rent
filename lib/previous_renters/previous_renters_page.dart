import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/previous_renters/previous_renters_info.dart';
import 'package:rent/previous_renters/previous_renters_view.dart';
import '../helping_classes/delete_renter/delete_renter_cubit.dart';

class PreviousRentersPage extends StatelessWidget {
  final PreviousRentersInfo previousRentersInfo;
  const PreviousRentersPage({super.key, required this.previousRentersInfo});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<DeleteRenterCubit>(
            create: (context) => DeleteRenterCubit(),
          ),
        ],
        child: PreviousRentersView(previousRentersInfo: previousRentersInfo,)
    );
  }
}