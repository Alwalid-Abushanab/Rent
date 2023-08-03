import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:rent/helping_classes/restore_property/restore_property_cubit.dart';
import 'package:rent/home/cubit/home_page_cubit.dart';
import 'package:rent/profile/profile_page.dart';
import 'package:rent/property/properties.dart';
import '../helping_classes/help_methods.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late int _indexSelected;
  DateTime? _currentBackPressTime;

  late List<dynamic> properties;
  late String name;
  late String email;
  late bool hasPrevProperties;
  late double totalAnnualRent;

  late bool _isLoading;

  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    /*
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];
      setState((){ });
    });
    */
    FlutterDownloader.registerCallback(downloadCallback);
    _isLoading = true;
    BlocProvider.of<HomePageCubit>(context).loadData();
    _indexSelected = 0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if(_indexSelected == 1){
          setState(() {
            _indexSelected = 0;
          });
          return Future.value(false);
        }
        leaveApp(_currentBackPressTime, context);
        _currentBackPressTime = DateTime.now();
        return Future.value(false);
      },
      child: propertyRestorationListener(),
    );
  }

  Widget propertyRestorationListener(){
    return BlocListener<RestorePropertyCubit, RestorePropertyState>(
      listener: (context, state) {
        if(state is RestoredProperty){
          BlocProvider.of<HomePageCubit>(context).loadData();
          Navigator.pop(context);
          Navigator.pop(context);
          setState(() {
            _indexSelected = 0;
          });
          showMessage(context, "Property Has Been Restored successfully");
        } else if(state is RestoringProperty){
          Navigator.pop(context);
          showProgressIndicator(context);
        } else if(state is RestorePropertyError){
          Navigator.pop(context);
          showMessage(context, 'Please Check Your Internet Connection And Try Again.');
        }
      },
      child: homePageListener(),
    );
  }

  Widget homePageListener(){
    return BlocListener<HomePageCubit, HomePageState>(
      listener: (context, state) {
        if(state is HomePageData){
          setState(() {
            name = state.name;
            email = state.email;
            hasPrevProperties = state.hasPrevProperties;
            properties = state.properties;
            totalAnnualRent = state.totalAnnualRent;
            _isLoading = false;
          });
        } else if(state is PropertyAdded){
          showMessage(context, "Property has been added successfully");
        } else {
          if(state is HomePageError){
            showMessage(context, 'Please Check Your Internet Connection And Try Again.');
          }
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isLoading ? 'Loading' : _indexSelected == 0 ? 'Properties' : 'Profile'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(),)
            : _indexSelected == 0
            ? Properties(properties: properties,)
            :ProfilePage(name: name, email: email, hasPrevProperties: hasPrevProperties, totalAnnualRent: totalAnnualRent),
        bottomNavigationBar: myNavBar(),
        floatingActionButton: _indexSelected == 0 ? _addPropertyButton() :  null,
      ),
    );
  }

  Widget myNavBar(){
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
      ]),
      child: GNav(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        gap: 5,
        activeColor: Colors.black,
        color: Colors.black,
        tabBackgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        iconSize: 24,
        tabs: const [
          GButton(
            icon: Icons.house_outlined,
            text: "Properties",
          ),
          GButton(
            icon: Icons.account_circle_rounded,
            text: "Profile",
            active: true,
          ),
        ],
        selectedIndex: _indexSelected,
        onTabChange: _itemSelected,
      ),
    );
  }

  void _itemSelected(int index){
    setState(() {
      _indexSelected = index;
    });
  }

  Widget _addPropertyButton(){
    return FloatingActionButton(
      onPressed: () {
        if(BlocProvider.of<HomePageCubit>(context).state is HomePageLoading){
          return;
        }
        addProperty(context);
      },
      child: const Icon(Icons.add),
    );
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }
}
