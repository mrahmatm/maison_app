import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:mai_son/GNavHomePage.dart';
import 'package:mai_son/functions/PapillonSwatch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppInfoPage.dart';
import 'SignUpPage.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: createMaterialColorPapillon(Color.fromRGBO(147, 112, 219, 1)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      routes: {
        SignUpPage.routeName: (context) => SignUpPage(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  //bool isLoggedIn = false;
  late String email;
  late String ic;

   // Function to save a value in cache
  Future<void> saveValueInCache(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }


  // Function to read a value from cache
  Future<String?> getValueFromCache(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    checkCache = prefs.getString(key);
  }

  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // Show a loading indicator
                SizedBox(height: 20),
                Text(message), // Show a loading message
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loginWithEmail(String email) async {
    setState(() {
      isLoading = true;
    });

    final url = 'https://maison-client.000webhostapp.com/mobile%20request.php'; // Add your URL here

    // Show the loading dialog before making the HTTP request
    showLoadingDialog(context, "Logging in...");

    final response = await http.post(
        Uri.parse(url),
        body: {
          'method': 'logInEmail',
          'patient_ICNum': ic,
          'patient_email': email,
        },
    );

    // Dismiss the loading dialog after receiving the response
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final result = response.body;
      if (result == '1') {
        // Authorized
        saveValueInCache("cachedEmail", email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login authorized')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GNaveHomePage(email: email)),
        );
      } else if (result == '0') {
        // Unauthorized
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login unauthorized')),
        );
      }
    } else {
      // Error occurred during the HTTP request
      print('Error: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
  }

  var checkCache;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      await getValueFromCache("cachedEmail");
      if(checkCache != null){
        email = checkCache;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GNaveHomePage(email: email)),
        );
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(), // Enable scrolling
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 160,
                    width: 160,
                    child: Center(
                      child: Image.asset('assets/maison-logo-no-line.png'),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "MAISON",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                    child: TextField(
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: "Email",
                      ),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                    child: TextField(
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: "IC Number (with '-')",
                      ),
                      onChanged: (value) {
                        setState(() {
                          ic = value;
                        });
                      },
                    ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(300, 50),
                      ),
                      onPressed: () {
                        loginWithEmail(email);
                      },
                      child: const Text("Login"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(300, 50),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, SignUpPage.routeName);
                      },
                      child: Text('Sign Up'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(300, 50),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AppInfoPage()),
                        );
                      },
                      child: Text('Application Info'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}