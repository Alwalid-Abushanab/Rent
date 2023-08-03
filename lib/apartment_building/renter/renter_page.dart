import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/apartment_building/renter/renter_view.dart';
import '../../helping_classes/edit_lease/edit_lease_cubit.dart';
import '../../helping_classes/pay_dialog/cubit/pay_dialog_cubit.dart';
import 'apt_renter_info.dart';

class RenterPage extends StatelessWidget {
  final ApartmentRenterInfo apartmentRenterInfo;
  const RenterPage({super.key, required this.apartmentRenterInfo});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<PayDialogCubit>(
            create: (context) => PayDialogCubit(),
          ),
          BlocProvider<EditLeaseCubit>(
            create: (context) => EditLeaseCubit(),
          ),
        ],
        child: RenterView(apartmentRenterInfo: apartmentRenterInfo,)
    );
  }
}