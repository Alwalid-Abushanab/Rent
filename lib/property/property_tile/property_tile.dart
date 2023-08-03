import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent/helping_classes/building_info.dart';
import 'package:rent/property/property_tile/cubit/property_tile_cubit.dart';
import '../../routes/route_generator.dart';

class PropertyTile extends StatefulWidget{
  final BuildingInfo buildingData;
  final int color;
  const PropertyTile({super.key, required this.buildingData, required this.color});

  @override
  State<PropertyTile> createState() => _PropertyTileState();
}

class _PropertyTileState extends State<PropertyTile>{
  late BuildingInfo buildingInfo;

  @override
  initState() {
    super.initState();
    buildingInfo = BuildingInfo(
      tileContext: context,
      buildingID: widget.buildingData.buildingID,
      buildingName: widget.buildingData.buildingName,
      buildingAddress: widget.buildingData.buildingAddress,
      buildingType: widget.buildingData.buildingType,
      buildingRent: widget.buildingData.buildingRent,
      buildingNotificationID: widget.buildingData.buildingNotificationID,
    );
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<PropertyTileCubit, PropertyTileState>(
        listener: (context, state) {
          if(state is PropertyTileUpdated){
            setState(() {
              buildingInfo = state.buildingInfo;
            });
          }
        },
        child: ListTile(
          leading: Icon(buildingInfo.buildingType == 'Office'
              ? Icons.business
              : buildingInfo.buildingType == 'House'
              ? Icons.house
              : Icons.apartment,
            color: Colors.white,
            size: 50,
          ),

          title: Text(buildingInfo.buildingName, textScaleFactor: 2,maxLines: 1, overflow: TextOverflow.ellipsis,),
          subtitle: Text(buildingInfo.buildingAddress, textScaleFactor: 1.3,maxLines: 1, overflow: TextOverflow.ellipsis,),
          trailing: Text(buildingInfo.buildingRent.toStringAsFixed(2),textScaleFactor: 1.5,maxLines: 1,),
          tileColor: widget.color == 1 ? Colors.orangeAccent : Colors.orange,
          onTap: () {

            if(buildingInfo.buildingType == 'Apartment Building'){
              Navigator.pushNamed(context, RouteGenerator.apartmentBuildingPage, arguments: buildingInfo);
            } else{
              Navigator.pushNamed(context, RouteGenerator.housePage, arguments: buildingInfo);
            }
          },
        ),
    );
  }
}