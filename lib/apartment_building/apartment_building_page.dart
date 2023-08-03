import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/apartment_building/cubit/apartment_building_cubit.dart';
import 'package:rent/apartment_building/apartment_building_view.dart';

import '../helping_classes/add_renter/cubit/add_renter_cubit.dart';
import '../helping_classes/building_info.dart';
import '../helping_classes/delete_property/delete_property_cubit.dart';
import '../helping_classes/edit_property/edit_property_cubit.dart';
import '../helping_classes/lease_termination/lease_termination_cubit.dart';
import '../helping_classes/pay_dialog/cubit/pay_dialog_cubit.dart';
import '../helping_classes/restore_renter/restore_renter_cubit.dart';

class ApartmentBuildingPage extends StatelessWidget {
  final BuildingInfo buildingInfo;
  const ApartmentBuildingPage({super.key, required this.buildingInfo});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<ApartmentBuildingCubit>(
            create: (context) => ApartmentBuildingCubit(buildingID: buildingInfo.buildingID),
          ),
          BlocProvider<AddRenterCubit>(
            create: (context) => AddRenterCubit(),
          ),
          BlocProvider<DeletePropertyCubit>(
            create: (context) => DeletePropertyCubit(),
          ),
          BlocProvider<LeaseTerminationCubit>(
            create: (context) => LeaseTerminationCubit(),
          ),
          BlocProvider<PayDialogCubit>(
            create: (context) => PayDialogCubit(),
          ),
          BlocProvider<EditPropertyCubit>(
            create: (context) => EditPropertyCubit(),
          ),
          BlocProvider<RestoreRenterCubit>(
            create: (context) => RestoreRenterCubit(),
          ),
        ],
        child: ApartmentBuildingView(buildingInfo: buildingInfo,)
    );
  }
}