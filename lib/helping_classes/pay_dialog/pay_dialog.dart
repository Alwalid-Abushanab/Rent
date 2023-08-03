import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/pay_dialog/cubit/pay_dialog_cubit.dart';

import '../renter_info.dart';

payDialog(BuildContext context, RenterInfo renterInfo,){
  BuildContext savedContext = context;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context){
      return AlertDialog(
        title: Text("Are you sure You want to mark the payment on "
            "${renterInfo.nextPaymentDate.year}/${renterInfo.nextPaymentDate.month}/"
            "${renterInfo.nextPaymentDate.day}"
            " for ${renterInfo.renterName} in ${renterInfo.buildingInfo.buildingName} building as paid?"
            " (The Payment Should be buildingRent\$)"
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context){
                  return AlertDialog(
                    title: const Text("Do you Want to Add A picture of the Receipt"),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            BlocProvider.of<PayDialogCubit>(savedContext).payWithoutReceipt(renterInfo);
                          },
                          child: const Text("No")
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          BlocProvider.of<PayDialogCubit>(savedContext).getFile(renterInfo);
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );
}