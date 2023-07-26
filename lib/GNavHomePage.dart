import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mai_son/functions/PapillonSwatch.dart';

import 'page/ManageAppointment.dart';
import 'page/ProfileScreen.dart';
import 'page/QueueScreen.dart';

class GNaveHomePage extends StatefulWidget {
  final String email;

  const GNaveHomePage({required this.email});

  @override
  _GNaveHomePageState createState() => _GNaveHomePageState();
}

class _GNaveHomePageState extends State<GNaveHomePage> {
  int currentTab = 0;
  late List<Widget> screens;

  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen;

  @override
  void initState() {
    super.initState();
    currentScreen = ManageAppointment(email: widget.email);
    screens = [
      ManageAppointment(email: widget.email),
      QueueScreen(email: widget.email),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MAISON",
                style: TextStyle(
                  fontSize: 22, // You can adjust the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.email,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12, // You can adjust the font size as needed
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: GNav(
        gap: 6.5,
        tabBackgroundColor: createMaterialColorPapillon(Color.fromRGBO(147, 112, 219, 1)),
        backgroundColor: Color.fromARGB(255, 222, 218, 218),
        activeColor: Colors.white,
        tabs: [
          GButton(
            icon: Icons.calendar_month_outlined,
            text: "Appointment",
            onPressed: () {
              setState(() {
                currentScreen = screens[0];
                currentTab = 0;
              });
            },
          ),
          GButton(
            icon: Icons.people_outline,
            text: "Queue",
            onPressed: () {
              setState(() {
                currentScreen = screens[1];
                currentTab = 1;
              });
            },
          ),
          GButton(
            icon: Icons.logout,
            text: "Log Out",
            onPressed: () {
              setState(() {
                currentScreen = screens[2];
                currentTab = 2;
              });
            },
          ),
        ],
      ),
    );
  }
}
