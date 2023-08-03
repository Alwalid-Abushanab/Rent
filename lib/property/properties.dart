import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/building_info.dart';
import 'package:rent/property/property_tile/cubit/property_tile_cubit.dart';
import 'package:rent/property/property_tile/property_tile.dart';
import '../helping_classes/help_methods.dart';

class Properties extends StatefulWidget {
  final List<dynamic> properties;
  const Properties({super.key, required this.properties});

  @override
  State<Properties> createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return list();
  }

  list() {
    if(widget.properties.isEmpty){
      return noProperties();
    }

    return ListView.builder(
      itemCount: widget.properties.length,
      reverse: true,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, i) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<PropertyTileCubit>(
              create: (context) => PropertyTileCubit(),
            ),
          ],
          child: PropertyTile(
            buildingData: BuildingInfo(
              buildingID: widget.properties[i].id,
              buildingType: widget.properties[i]['PropertyType'],
              buildingRent: widget.properties[i]['PropertyYearlyRent'],
              buildingAddress: widget.properties[i]['PropertyAddress'],
              buildingName: widget.properties[i]['PropertyName'],
              buildingNotificationID: widget.properties[i]['NotificationID'],
            ),
            color: i % 2,
          ),
        );
      },
    );
  }

  noProperties() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              addProperty(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              "You do not have any registered properties.\nYou can add a Property by clicking on the + button",
              textAlign: TextAlign.center,
              textScaleFactor: 1.3,
            ),
          )
        ],
      ),
    );
  }
}