import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/building_info.dart';
import 'package:rent/helping_classes/delete_property/delete_property_cubit.dart';
import 'package:rent/helping_classes/edit_lease/edit_lease_cubit.dart';
import 'package:rent/helping_classes/edit_property/edit_property_cubit.dart';
import 'package:rent/helping_classes/permanently_delete_property/permanently_delete_property_cubit.dart';
import 'package:rent/helping_classes/renter_info.dart';
import 'package:rent/helping_classes/restore_property/restore_property_cubit.dart';
import 'package:rent/helping_classes/restore_renter/restore_renter_cubit.dart';
import 'package:rent/previous_renters/previous_renters_info.dart';
import 'package:rent/routes/route_generator.dart';
import '../helping_classes/lease_termination/lease_termination_cubit.dart';
import 'delete_renter/delete_renter_cubit.dart';

Widget menu({
  required BuildContext context,
  PopupMenuItem? prevRentersItem,
  PopupMenuItem? leaseEditingItem,
  PopupMenuItem? leaseTerminationItem,
  PopupMenuItem? propertyEditingItem,
  PopupMenuItem? propertyDeletionItem,
  PopupMenuItem? renterRestorationItem,
  PopupMenuItem? renterDeletionItem,
  PopupMenuItem? propertyRestorationItem,
  PopupMenuItem? propertyPermanentDeletionItem,
}) {
  return GestureDetector(
    onTap: () {
      showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(100, 100, 0, 0),
        items: <PopupMenuEntry>[
          if(prevRentersItem != null)
            prevRentersItem,

          if(leaseEditingItem != null)
            leaseEditingItem,

          if(leaseTerminationItem != null)
            leaseTerminationItem,

          if(propertyEditingItem != null)
            propertyEditingItem,

          if(propertyDeletionItem != null)
            propertyDeletionItem,

          if(renterRestorationItem != null)
            renterRestorationItem,

          if(renterDeletionItem != null)
            renterDeletionItem,

          if(propertyRestorationItem != null)
            propertyRestorationItem,

          if(propertyPermanentDeletionItem != null)
            propertyPermanentDeletionItem,
        ],
      );
    },
    child: const Icon(
        Icons.more_vert
    ),
  );
}

PopupMenuItem previousRentersItem(BuildContext context, BuildingInfo buildingInfo, bool hasPrevRenters, bool hasSpace, bool loading){
  return PopupMenuItem(
    child: ListTile(
      title: const Text('Previous Renters'),
      onTap: () {
        if(!loading){
          if(hasPrevRenters){
            Navigator.pushNamed(
              context,
              RouteGenerator.previousRentersPage,
              arguments: PreviousRentersInfo(
                context: context,
                buildingInfo: buildingInfo,
                buildingHasSpace: hasSpace,
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: const Text('This Property does not have any previous renters'),
                  actions: [
                    ElevatedButton(
                      onPressed: () =>  Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      },
    ),
  );
}

PopupMenuItem terminateLeaseItem(BuildContext context, RenterInfo renterInfo, bool loading){
  return PopupMenuItem(
    child: ListTile(
      title: const Text('Terminate the Lease'),
      onTap: () {
        if(!loading){
          BuildContext savedContext = context;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Are you sure about terminating ${renterInfo.renterName}\' lease?'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<LeaseTerminationCubit>(savedContext).terminateLease(
                        renterInfo.buildingInfo.buildingID,
                        renterInfo.renterID,
                        renterInfo.rent*12/renterInfo.paymentFrequency,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Terminate"),
                  ),
                ],
              );
            },
          );
        }
      },
    ),
  );
}


PopupMenuItem deletePropertyItem(BuildContext context, String buildingID, bool loading){
  return PopupMenuItem(
    child: ListTile(
      title: const Text('Delete Property'),
      onTap: () {
        if(!loading){
          BuildContext savedContext = context;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Are you sure about deleting this Property?'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<DeletePropertyCubit>(savedContext).deleteProperty(buildingID);
                      Navigator.pop(context);
                    },
                    child: const Text("Delete"),
                  ),
                ],
              );
            },
          );
        }
      },
    ),
  );
}

PopupMenuItem editLeaseItem(BuildContext context, RenterInfo renterInfo, bool loading){
  return PopupMenuItem(
    child: ListTile(
      title: const Text('Edit Lease'),
      onTap: () {
        if(!loading){
          TextEditingController rentController = TextEditingController(text: renterInfo.rent.toString());
          TextEditingController paymentFrequencyController = TextEditingController(text: renterInfo.paymentFrequency.toString());

          BuildContext savedContext = context;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              String? rentErrorText;
              String? paymentFrequencyErrorText;

              void validateFields() {
                rentErrorText = rentController.text.isEmpty ? 'Field is required' : null;
                paymentFrequencyErrorText = paymentFrequencyController.text.isEmpty ? 'Field is required' : null;
              }

              void clearErrorText(TextEditingController controller) {
                if (controller.text.isNotEmpty) {
                  if (controller == rentController) {
                    rentErrorText = null;
                  } else if (controller == paymentFrequencyController) {
                    paymentFrequencyErrorText = null;
                  }
                }
              }

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Edit Lease Agreement"),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
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
                          const SizedBox(height: 10),
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
                          if (rentErrorText == null &&
                              paymentFrequencyErrorText == null) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('do you want to change rent from ${renterInfo.rent} every ${renterInfo.paymentFrequency} month to ${rentController.text} every ${paymentFrequencyController.text} month?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        BlocProvider.of<EditLeaseCubit>(savedContext).editLease(
                                          renterInfo.buildingInfo.buildingID,
                                          renterInfo.renterID,
                                          renterInfo.rent*12/renterInfo.paymentFrequency,
                                          double.parse(rentController.text),
                                          int.parse(paymentFrequencyController.text),
                                        );
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
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
      },
    ),
  );
}

PopupMenuItem editPropertyItem(BuildContext context, BuildingInfo buildingInfo, bool loading){
  return PopupMenuItem(
    child: ListTile(
        title: const Text('Edit Building Name'),
      onTap: () {
        if(!loading){
          TextEditingController buildingNameController = TextEditingController(text: buildingInfo.buildingName);

          BuildContext savedContext = context;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              String? buildingNameErrorText;

              void validateFields() {
                buildingNameErrorText = buildingNameController.text.isEmpty ? 'Field is required' : null;
              }

              void clearErrorText(TextEditingController controller) {
                if (buildingNameController.text.isNotEmpty) {
                  if (controller == buildingNameController) {
                    buildingNameErrorText = null;
                  }
                }
              }

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Edit Building Name"),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: buildingNameController,
                            decoration: InputDecoration(
                              labelText: 'Building Name',
                              errorText: buildingNameErrorText,
                            ),
                            keyboardType: TextInputType.text,
                            onChanged: (_) => setState(() => clearErrorText(buildingNameController)),
                          ),
                          const SizedBox(height: 10),
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
                          if (buildingNameErrorText == null) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Are you sure about changing the Property name from ${buildingInfo.buildingName} to ${buildingNameController.text}?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        BlocProvider.of<EditPropertyCubit>(savedContext).editProperty(
                                          buildingInfo.buildingID,
                                          buildingNameController.text,
                                        );
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
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
      },
    ),
  );
}

PopupMenuItem restoreRenterItem(BuildContext context, RenterInfo renterInfo, bool canBeRestored){
  return PopupMenuItem(
    child: ListTile(
      title: const Text('Restore Renter'),
      onTap: () {
        if(canBeRestored){
          BlocProvider.of<RestoreRenterCubit>(context).restoreRenter(
              renterInfo.buildingInfo.buildingID,
              renterInfo.renterID,
              renterInfo.rent*12/renterInfo.paymentFrequency
          );
        } else {
          showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: Text('The renter can not be restored because the ${renterInfo.buildingInfo.buildingType} is rented'),
                actions: [
                  ElevatedButton(
                    onPressed: () =>  Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      },
    ),
  );
}

PopupMenuItem deleteRenter(BuildContext context, RenterInfo renterInfo){
  return PopupMenuItem(
    child: ListTile(
      title: const Text('Delete Renter'),
      onTap: () {
        BuildContext savedContext = context;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are you sure about deleting this renter permanently?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<DeleteRenterCubit>(savedContext).deleteRenter(
                      renterInfo.buildingInfo.buildingID,
                      renterInfo.renterID,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}

PopupMenuItem deletePropertyPermanently(BuildContext context, String buildingID){
  return PopupMenuItem(
    child: ListTile(
      title: const Text('Delete Permanently'),
      onTap: () {
        BuildContext savedContext = context;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are you sure about deleting this Property? it can not be restored later'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<PermanentlyDeletePropertyCubit>(savedContext).permanentlyDeleteProperty(buildingID);
                    Navigator.pop(context);
                  },
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}

PopupMenuItem restoreProperty(BuildContext context, String buildingID){
  return PopupMenuItem(
    child: ListTile(
      title: const Text('Restore Property'),
      onTap: () {
        BlocProvider.of<RestorePropertyCubit>(context).restoreProperty(buildingID);
      },
    ),
  );
}