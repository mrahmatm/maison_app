import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mai_son/functions/PapillonSwatch.dart';

class QueueScreen extends StatefulWidget {
  final String email;

  const QueueScreen({required this.email});

  @override
  _QueueScreenState createState() => _QueueScreenState();
}

bool isInRange = false;
bool isQueueing = false;
bool hasAppointment = false;
String queueNumber = "";
String responseText = "Nothing";
bool isLoading = false;
final Uri url = Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
int peopleInFrontCount = 0;

class _QueueScreenState extends State<QueueScreen> {

  //11
  Future<void> checkIfQueueing() async{

    final String email = widget.email;

  try{
    final http.Response response = await http.post(
      url,
      body: {
        'method': 'checkIfQueueing',
        'patient_email': email,
      },
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      //hasAppointment = false;
      Map<String, dynamic> data = jsonDecode(responseBody);
      //bool localIsQueueing = false;
      print("email to check for queue: "+email);
      print("isQueueing status:"+responseBody);
      bool holdTempBeforeCheck = isQueueing;
      if(data['isQueueing'] == 1){
        isQueueing = true;
        queueNumber = data['q_ID'].toString();
        print("is queueing! number: "+queueNumber);
        if(!holdTempBeforeCheck){
          _showSnackBar("You are already queueing!", Colors.red);
        }
        containerColor = ValueNotifier<Color>(Colors.green);
        //setState(() {});
      }else{
        isQueueing = false;
        queueNumber = "NONE";
        _showSnackBar("You are not queueing.", Colors.green);
      }
      if(holdTempBeforeCheck != isQueueing){
        setState(() {});
      }
      //setState(() {});
    } else {
      _showSnackBar("Error authenticating with server!", Colors.red);
    }
  }catch (e){
    if (e is SocketException) {
      // Handle the socket connection error
      _showSnackBar("Connection error: Please check your internet connection.", Colors.red);
      // You can also log the error for debugging purposes if needed
      print("SocketException occurred: $e");
    } else {
      // Handle other types of exceptions (if any)
      _showSnackBar("An error occurred: $e", Colors.red);
    }
    setState(() {});
  }
    
  }
  
  //10
  Future<void> attemptQueueAppointment() async{
    setState(() {
      isLoading = true;
    });

    showLoadingDialog("Queueing for your appointment...");

    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date and time to the desired format
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(now);

    final Uri url = Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
    final String email = widget.email;

    final http.Response response = await http.post(
      url,
      body: {
        'method': 'attemptQueueAppointment',
        'patient_email': email,
        'datetime': formattedDateTime,
      },
    );

    setState(() {
      isLoading = false;
    });

    // Dismiss the loading dialog after receiving the response
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      hasAppointment = false;
      if (responseBody.trim() == '1') {
        isQueueing = true;
        hasAppointment = false;
        _showSnackBar("You may now queue for your appointment!", Colors.green);
      } else if(responseBody.trim() == '-1'){
        _showSnackBar("You are too early, check appointment time!", Colors.yellow);
      } else if(responseBody.trim() == '-2'){
        isQueueing = true;
        hasAppointment = false;
        _showSnackBar("You are late, but you may queue!", createMaterialColorPapillon(Color.fromRGBO(147, 112, 219, 1)));
      } else if(responseBody.trim() == '-3'){
        //no appointment
        hasAppointment = false;
      } else{
        _showSnackBar("Error checking for appointment!", Colors.red);
      }

      setState(() {});
    } else {
      _showSnackBar("Error authenticating with server!", Colors.red);
    }
  }

  //9
  Future<void> checkAppointment() async{
    setState(() {
      isLoading = true;
    });

    showLoadingDialog("Checking for appointment...");

    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date and time to the desired format
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(now);

    final Uri url = Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
    final String email = widget.email;

    final http.Response response = await http.post(
      url,
      body: {
        'method': 'checkAppointment',
        'patient_email': email,
        'datetime': formattedDateTime,
      },
    );

    setState(() {
      isLoading = false;
    });

    // Dismiss the loading dialog after receiving the response
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      hasAppointment = false;
      if (responseBody.trim() == '1') {
        _showSnackBar("You may now queue for your appointment!", Colors.green);
        hasAppointment = true;
        setState(() {

        });
      } else if(responseBody.trim() == '-1'){
        _showSnackBar("You are too early, check appointment time!", Colors.yellow);
      } else if(responseBody.trim() == '-2'){
        _showSnackBar("You are late, but you may queue!", createMaterialColorPapillon(Color.fromRGBO(147, 112, 219, 1)));
        hasAppointment = true;
      } else if(responseBody.trim() == '-3'){
        //no appointment
        //_showSnackBar("You are too early, check appointment time!", Colors.yellow);
        //hasAppointment = true;
      } else{
        _showSnackBar("Error checking for appointment!", Colors.red);
      }
    } else {
      _showSnackBar("Error authenticating with server!", Colors.red);
    }
  }

  //8
  Future<void> peopleInFront() async{
    //only done when user is queueing
    if(!isQueueing){
      return;
    }

    final Uri url = Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
    final String email = widget.email;

    final http.Response response = await http.post(
      url,
      body: {
        'method': 'peopleInFront',
        'patient_email': email,
      },
    );

    if (response.statusCode == 200) {
      try{
          final String responseBody = response.body;
          peopleInFrontCount = int.parse(responseBody);
          print("people in front: "+peopleInFrontCount.toString());
          //set display people in front
      }catch (e){
          _showSnackBar("Abnormal people in front response!", Colors.red);
          print("error peopleInFront: $e");
      }
    } else {
      _showSnackBar("Error authenticating with server!", Colors.red);
    }
  }

  //7
  Future<void> queueWalkIn() async{
    //only done when user is queueing
    if(isQueueing){
      return;
    }

    showLoadingDialog("Queueing...");

    final Uri url = Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
    final String email = widget.email;

    final http.Response response = await http.post(
      url,
      body: {
        'method': 'queueWalkIn',
        'patient_email': email,
      },
    );

    // Dismiss the loading dialog after receiving the response
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      int intResponse = int.parse(responseBody);
      if (intResponse == 1) {
        isQueueing = true;
        _showSnackBar("You are now queueing!", Colors.green);
        //checkIfQueueing();
        setState(() {});
      } else if(intResponse == 0){
        _showSnackBar("Error queueing for walk-in!", Colors.red);
      }

      setState(() {});
    } else {
      _showSnackBar("Error authenticating with server!", Colors.red);
    }
    
  }

  //6
  Future<void> checkLocation() async {

  //showLoadingDialog("Checking your location...");

  Position position = await getCurrentLocation();
  double latitude = position.latitude;
  double longitude = position.longitude;

  String strLat = latitude.toString();
  String strLng = longitude.toString();
  try{
    final Uri url = Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
    final String email = widget.email;

    final http.Response response = await http.post(
      url,
      body: {
        'method': 'checkLocation',
        'latitude': strLat,
        'longitude': strLng,
      },
    );
    //print("latitude to be sent: "+strLat);
    //print("longitude to be sent: "+strLng);

    // Dismiss the loading dialog after receiving the response
    //Navigator.of(context).pop();
    if (response.statusCode == 200) {
    final String responseBody = response.body;
    //print("response: "+responseBody);
    int intResponse = int.parse(responseBody);
    bool holdTempBeforeCheck = isInRange;
    if(intResponse == 1){
      isInRange = true;
      if(!holdTempBeforeCheck){
        _showSnackBar("You are within queuing range!", Colors.green);
        containerColor = ValueNotifier<Color>(Colors.green);
        setState(() {});
      }
    }else if(intResponse == 0){
      if(holdTempBeforeCheck){
        _showSnackBar("You are not within queuing range!", Colors.red);
        containerColor = ValueNotifier<Color>(Colors.red);
        setState(() {});
      }
    }else{
      _showSnackBar("Abnormal response from server!", Colors.red);
    }
  } else {
    _showSnackBar("Error authenticating with server!", Colors.red);
  }
  }catch(e){
if (e is SocketException) {
      // Handle the socket connection error
      _showSnackBar("Connection error: Please check your internet connection.", Colors.red);
      // You can also log the error for debugging purposes if needed
      print("SocketException occurred: $e");
    } else {
      // Handle other types of exceptions (if any)
      _showSnackBar("An error occurred: $e", Colors.red);
    }
    //setState(() {});
  }

}

  void _showSnackBar(String message, Color backgroundColor) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 210.0), // Adjust the top margin value as needed
      ),
    );
  }
}

  
  bool stringToBool(String value) {
    return value.toLowerCase() == 'true';
  }

  // Global variable to track the color
  ValueNotifier<Color> containerColor =
      ValueNotifier<Color>(createMaterialColorPapillon(Color.fromARGB(255, 186, 116, 178)));

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location service isn't enabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions were declined.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Locations are permanently denied!");
    }

    return await Geolocator.getCurrentPosition();
  }

  void showLoadingDialog(String message){
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

  // Declare a variable to hold the timer
  Timer? periodicTimer;

  // Function to start the periodic timer
  void startPeriodicTimer() {
    // Check if the timer is null to avoid creating multiple timers
    // ignore: prefer_conditional_assignment
    if (periodicTimer == null) {
      // Create a periodic timer that calls the peopleInFront function every 5 seconds
      periodicTimer = Timer.periodic(Duration(seconds: 7), (timer) {
        // Call the peopleInFront function inside the timer callback
        peopleInFront();
        checkIfQueueing();
        if(!isQueueing){
          stopPeriodicTimer();
        }
      });
    }
  }

  void stopPeriodicTimer() {
  // Check if the timer is not null to ensure it is currently running
  if (periodicTimer != null) {
    // Cancel the periodic timer
    periodicTimer?.cancel();
    periodicTimer = null; // Reset the timer variable
  }
}

// Declare a variable to hold the periodic timer
Timer? periodicCheckLocationTimer;
void startPeriodicCheckLocation() {
  // Check if the timer is null to avoid creating multiple timers
  // ignore: prefer_conditional_assignment
  if (periodicCheckLocationTimer == null) {
    // Create a periodic timer that calls the checkLocation function every 5 seconds
    int localSeconds;
    if(!isInRange){
      localSeconds = 8;
    }else{
      localSeconds = 15;
    }
    periodicCheckLocationTimer = Timer.periodic(Duration(seconds: localSeconds), (timer) {
      // Call the checkLocation function inside the timer callback
      checkLocation();
    });
  }
}

void stopPeriodicCheckLocation() {
  // Check if the timer is not null to ensure it is currently running
  if (periodicCheckLocationTimer != null) {
    // Cancel the periodic timer
    periodicCheckLocationTimer?.cancel();
    periodicCheckLocationTimer = null; // Reset the timer variable
  }
}

Future<http.Response> getWithRetry(String url, {int maxRetries = 3}) async {
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response; // Success, return the response
      } else {
        // Handle non-200 status code if needed
        return Future.error('Failed with status code ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or any exceptions here
      print('Error occurred: $e');
    }

    // Increment the retry count and introduce a delay before retrying
    retryCount++;
    await Future.delayed(Duration(seconds: 5));
  }

  // Retry attempts exceeded, return an error response or throw an exception
  return Future.error('Failed after $maxRetries attempts');
}



  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      await checkIfQueueing();
      if(!isQueueing){
        //await checkLocation();
        await checkAppointment();
        stopPeriodicTimer();
        startPeriodicCheckLocation();
      }else{
        stopPeriodicCheckLocation();
        startPeriodicTimer();
        peopleInFront();
      }
      
      setState(() {});
    });

    //checkLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

Future<bool> _onBackPressed() async {
  // Custom logic for back button press here
  // For example, you can show a dialog to confirm if the user wants to exit
  bool confirmExit = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Exit App'),
      content: Text('Are you sure you want to exit?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            // Close the app when the user selects "Yes"
            SystemNavigator.pop(); // This will close the app
          },
          child: Text('Yes'),
        ),
      ],
    ),
  );

  return confirmExit ?? false;
}


  @override
  Widget build(BuildContext context) {
    //checkLocation();
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
      body: Column(
        children: [
          ValueListenableBuilder<Color>(
            valueListenable: containerColor,
            builder: (context, color, child) {
              return Container(
                color: color,
                width: MediaQuery.of(context).size.width,
                height: 450,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Your Queue Number:", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 25),
                    Text(
                      queueNumber
                      , style: TextStyle(color: Colors.white, fontSize: 50)),
                    //DynamicTextSpace(text: dynamicText),
                    SizedBox(height: 25),
                    Text("Status: ", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 25),
                    Text(
                      isInRange ?
                        isQueueing ?
                          "You are now queueing!"
                          :"You are within the clinic's queueing range"
                        : isQueueing?
                          "You are now queueing!"
                          : ""
                        "You are outside the clinic's queueing range",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    SizedBox(height: 25),
                    Text(
                      isQueueing?
                        peopleInFrontCount > 0?
                          "People in front of you: "+peopleInFrontCount.toString()
                        : "You will be called very soon!"
                      :"",
                      style: TextStyle(color: Colors.white),
                    ), // Display the server response
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isInRange && !isQueueing ? () => queueWalkIn() : null,
                        child: Text("Queue Walk-in"),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isInRange && hasAppointment && !isQueueing ? () => attemptQueueAppointment() : null,
                        child: Text("Queue Appointment"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
                      onPressed: () async {
                        //checkIfQueueing();
                        //setState(() {});
                        //await Navigator.push(context, MaterialPageRoute(builder: (context) => AnotherPage()));
                        //showLoadingDialog("Refreshing...");
                        //Navigator.of(context).pop();
                        //_reloadPage(context);
                      },
                      child: Icon(Icons.refresh),
                    ),
    ),
      );
    
  }
}

