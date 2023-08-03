import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/add_renter/cubit/add_renter_cubit.dart';


void addRenter(BuildContext context, String buildingType, String buildingID) {
  TextEditingController nameController = TextEditingController();
  TextEditingController startDateController  = TextEditingController();
  TextEditingController rentController  = TextEditingController();
  TextEditingController paymentFrequencyController  = TextEditingController();
  TextEditingController apartNumController  = TextEditingController();
  DateTime? selectedDate;

  BuildContext savedContext = context;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      String? nameErrorText;
      String? startDateErrorText;
      String? rentErrorText;
      String? paymentFrequencyErrorText;
      String? apartNumErrorText;

      void validateFields() {
        nameErrorText = nameController.text.isEmpty ? 'Field is required' : null;
        startDateErrorText = startDateController.text.isEmpty ? 'Field is required' : null;
        rentErrorText = rentController.text.isEmpty ? 'Field is required' : null;
        paymentFrequencyErrorText = paymentFrequencyController.text.isEmpty ? 'Field is required' : null;
        if(buildingType == 'Apartment Building'){
          apartNumErrorText = apartNumController.text.isEmpty ? 'Field is required' : null;
        }
      }

      void clearErrorText(TextEditingController controller) {
        if (controller.text.isNotEmpty) {
          if (controller == nameController) {
            nameErrorText = null;
          } else if (controller == startDateController) {
            startDateErrorText = null;
          } else if (controller == rentController) {
            rentErrorText = null;
          } else if (controller == paymentFrequencyController) {
            paymentFrequencyErrorText = null;
          } else if (controller == apartNumController) {
            apartNumErrorText = null;
          }
        }
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add a Renter"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Renter Name',
                      errorText: nameErrorText,
                    ),
                    onChanged: (_) => setState(() => clearErrorText(nameController)),
                  ),
                  if(buildingType == 'Apartment Building')
                    TextField(
                      controller: apartNumController,
                      decoration: InputDecoration(
                        labelText: 'Apartment Number',
                        errorText: apartNumErrorText,
                      ),
                      onChanged: (_) => setState(() => clearErrorText(apartNumController)),
                    ),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null && picked != selectedDate) {
                        selectedDate = picked;
                        String month = selectedDate!.month.toString().padLeft(2, '0');
                        String day = selectedDate!.day.toString().padLeft(2, '0');
                        startDateController.text = '${selectedDate!.year}/$month/$day';
                      }
                      setState(() => clearErrorText(startDateController));
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: startDateController,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          errorText: startDateErrorText,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: rentController,
                    decoration: InputDecoration(
                      labelText: 'Rent',
                      errorText: rentErrorText,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => clearErrorText(rentController)),
                  ),
                  TextField(
                    controller: paymentFrequencyController,
                    decoration: InputDecoration(
                      labelText: 'Payment every X months',
                      errorText: paymentFrequencyErrorText,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => clearErrorText(paymentFrequencyController)),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  validateFields();
                  if (nameErrorText == null &&
                      startDateErrorText == null &&
                      rentErrorText == null &&
                      paymentFrequencyErrorText == null &&
                      apartNumErrorText == null) {
                    BlocProvider.of<AddRenterCubit>(savedContext).addRenter(
                      buildingID,
                      nameController.text,
                      selectedDate!,
                      double.parse(rentController.text),
                      int.parse(paymentFrequencyController.text),
                      apartNumController.text,
                    );
                    Navigator.pop(context);
                  } else {
                    setState(() {});
                  }
                },
                child: const Text("Save"),
              ),
            ],
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
          );
        },
      );
    },
  );
}