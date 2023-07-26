import 'package:flutter/material.dart';

import 'page/ManageAppointment.dart';
import 'page/ProfileScreen.dart';
import 'page/QueueScreen.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({required this.email});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentTab = 0;
  

  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen;

  @override
  void initState() {
    super.initState();
    final List<Widget> screens = [
    ManageAppointment(email: widget.email),
    ProfileScreen(),
    QueueScreen(email: widget.email)
  ];
    currentScreen = screens[currentTab];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("MAISON")),
        automaticallyImplyLeading: false,
      ),
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            currentScreen = QueueScreen(email: widget.email);
            currentTab = 2;
          });
        },
        backgroundColor: currentTab == 2 ? Colors.redAccent : Colors.white,
        shape: const StadiumBorder(side: BorderSide(color: Colors.black, width: 1)),
        child: const Text(
          "Queue",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                // Left
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = ManageAppointment(email: widget.email);
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          color: currentTab == 0 ? Colors.red : Colors.black,
                        ),
                        Text(
                          "Appointment",
                          style: TextStyle(color: currentTab == 0 ? Colors.red : Colors.black),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                // Right
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = ProfileScreen();
                        currentTab = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          color: currentTab == 1 ? Colors.red : Colors.black,
                        ),
                        Text(
                          "My Account",
                          style: TextStyle(color: currentTab == 1 ? Colors.red : Colors.black),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
