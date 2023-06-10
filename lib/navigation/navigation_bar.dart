import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../routes/route_generator.dart';

class MyNavigationBar extends StatefulWidget {
  static const int homeIndex = 1;
  static const int rentersIndex = 0;
  final int pageIndex;

  const MyNavigationBar({super.key, required this.pageIndex});

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}
class _MyNavigationBarState extends State<MyNavigationBar> {
  late int indexSelected;

  @override
  void initState() {
    super.initState();
    indexSelected = widget.pageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
      ]),
      child: GNav(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        gap: 5,
        activeColor: Colors.black,
        tabBackgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        iconSize: 24,
        tabs: const [
          GButton(
            icon: Icons.edit_note,
            text: "Renters",
          ),
          GButton(
            icon: Icons.calendar_month,
            text: "Calendar",
            active: true,
          ),
        ],
        selectedIndex: indexSelected,
        onTabChange: (index){
          if(index == indexSelected){
            return;
          }
          setState(() {
            indexSelected = index;
          });
          Navigator.pushNamed(
              context,
              indexSelected == MyNavigationBar.homeIndex ?
                RouteGenerator.homePage :
                RouteGenerator.renterPage
          );
        },
      ),
    );
  }
}