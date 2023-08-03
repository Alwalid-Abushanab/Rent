import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/add_renter/cubit/add_renter_cubit.dart';
import 'package:rent/helping_classes/building_info.dart';
import 'package:rent/helping_classes/delete_property/delete_property_cubit.dart';
import 'package:rent/helping_classes/edit_lease/edit_lease_cubit.dart';
import 'package:rent/helping_classes/edit_property/edit_property_cubit.dart';
import '../helping_classes/lease_termination/lease_termination_cubit.dart';
import 'package:rent/helping_classes/pay_dialog/cubit/pay_dialog_cubit.dart';
import 'package:rent/house/cubit/house_cubit.dart';

import '../helping_classes/restore_renter/restore_renter_cubit.dart';
import 'house_view.dart';

class HousePage extends StatelessWidget {
  final BuildingInfo buildingInfo;
  const HousePage({super.key, required this.buildingInfo});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HouseCubit>(
            create: (context) => HouseCubit(buildingID: buildingInfo.buildingID),
          ),
          BlocProvider<PayDialogCubit>(
            create: (context) => PayDialogCubit(),
          ),
          BlocProvider<LeaseTerminationCubit>(
            create: (context) => LeaseTerminationCubit(),
          ),
          BlocProvider<AddRenterCubit>(
            create: (context) => AddRenterCubit(),
          ),
          BlocProvider<DeletePropertyCubit>(
            create: (context) => DeletePropertyCubit(),
          ),
          BlocProvider<EditLeaseCubit>(
            create: (context) => EditLeaseCubit(),
          ),
          BlocProvider<EditPropertyCubit>(
            create: (context) => EditPropertyCubit(),
          ),
          BlocProvider<RestoreRenterCubit>(
            create: (context) => RestoreRenterCubit(),
          ),
        ],
        child: HouseView(buildingInfo: buildingInfo,)
    );
  }
}