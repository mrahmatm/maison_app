import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ManageAppointment extends StatefulWidget {
  final String email;

  const ManageAppointment({required this.email});

  @override
  _ManageAppointmentState createState() => _ManageAppointmentState();
}

class _ManageAppointmentState extends State<ManageAppointment> {
  List<Map<String, String>> appointments = [];
  bool isLoading = true;
  List<String> appointmentTypes = [];
  String selectedAppointmentType = '';

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      await fetchAppointmentTypes();

      // Set initial value for selectedAppointmentType
      if (appointmentTypes.isNotEmpty) {
        selectedAppointmentType = appointmentTypes.first;
      }

      setState(() {});
    });

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      fetchAppointments();
    });
  }

  Future<void> fetchAppointmentTypes() async {
    try{
        Uri url = Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
      final http.Response response = await http.post(
      url,
      body: {'method': 'fetchAppointmentTypes'},
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      if (responseBody == '0') {
        _showSnackBar('No appointment types found.', Colors.red);
        return;
      }

      final List<dynamic> appointmentTypeJson = json.decode(responseBody);

      setState(() {
        appointmentTypes = appointmentTypeJson
            .map((type) => type['svc_desc'] as String)
            .toList();
        isLoading = false;
      });
    } else {
      _showSnackBar(
          'Failed to fetch appointment types. Error: ${response.statusCode}', Colors.red);
      setState(() {
        isLoading = false;
      });
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
    setState(() {});
    }
    
  }

  Future<void> fetchAppointments() async {
    setState(() {
      isLoading = true;
    });

    final Uri url =
        Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
    final String email = widget.email;

    final http.Response response = await http.post(
      url,
      body: {
        'method': 'fetchPatientAppointment',
        'patient_email': email,
      },
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      if (responseBody == '0') {
        _showSnackBar('No appointments found.', Colors.yellow);
        return;
      }

      setState(() {
        appointments.addAll(parseAppointments(responseBody));
      });
    } else {
      _showSnackBar(
          'Failed to fetch appointments. Error: ${response.statusCode}', Colors.red);
    }
  }

  void _refreshAppointments() {
    setState(() {
      isLoading = true;
      appointments.clear(); // Clear the existing appointments
    });

    fetchAppointments();
  }

  void _createAppointment() {
    setState(() {
      isLoading = true; // Set isLoading to true to show the loading state
    });

    final Uri url = Uri.parse('https://maison-client.000webhostapp.com/mobile%20request.php');
    final String email = widget.email;
    final String selectedService = selectedAppointmentType;

    final String date = "${selectedDate.toLocal()}".split(' ')[0]; // Trim the time part
    final String time = selectedTime.format(context); // Use the separately picked time

    final String datetime = "$date $time";
    print("the datetime produced before sending: " + datetime);
    print("the service selected before sending: " + selectedService);

    final Future<http.Response> responseFuture = http.post(
      url,
      body: {
        'method': 'newAppointment',
        'patient_email': email,
        'app_datetime': datetime,
        'svc_code': selectedService,
      },
    );

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
                Text('Creating Appointment...'), // Show a loading message
              ],
            ),
          ),
        );
      },
    );

    responseFuture.then((http.Response response) {
      Navigator.pop(context); // Close the loading dialog

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        if (responseBody.trim() == '1') {
          // Appointment created successfully
          _showSnackBar('Appointment created successfully', Colors.green);
          fetchAppointments();
          Navigator.pop(context);
        } else if (responseBody.trim() == '-1') {
          _showSnackBar('Invalid time', Colors.red);
        } else if (responseBody.trim() == '-2') {
          _showSnackBar('Invalid date', Colors.red);
        } else if (responseBody.trim() == '-3'){
          _showSnackBar('Overlapping appointment(s)', Colors.red);
        }else {
          _showSnackBar('Failed to create appointment', Colors.red);
        }
      } else {
        _showSnackBar('Failed to create appointment. Error: ${response.statusCode}', Colors.red);
      }

      setState(() {
        isLoading = false; // Set isLoading to false to hide the loading state
      });
    }).catchError((error) {
      Navigator.pop(context); // Close the loading dialog
      _showSnackBar('Failed to create appointment. Error: $error', Colors.red);

      setState(() {
        isLoading = false; // Set isLoading to false to hide the loading state
      });
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: 210.0), // Adjust the top margin value as needed
    ),
  );
}


  List<Map<String, String>> parseAppointments(String responseBody) {
    final List<Map<String, String>> parsedList = [];

    try {
      final dynamic appointmentJson = json.decode(responseBody);
      if (appointmentJson is List) {
        for (var appointmentData in appointmentJson) {
          final String appDatetime = appointmentData['app_datetime'] ?? '';
          final String svcName = appointmentData['svc_name'] ?? '';

          final List<String> datetimeParts = appDatetime.split(' ');
          final String date = datetimeParts[0];
          final String time = datetimeParts[1];

          final Map<String, String> appointmentMap = {
            'date': date,
            'time': time,
            'title': svcName,
          };

          parsedList.add(appointmentMap);
        }
      }
    } catch (e) {
      print('recived: '+responseBody +'Error parsing appointments: $e');
    }

    return parsedList;
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime tomorrow = currentDate.add(const Duration(days: 1));

    // Set initial date to tomorrow
    DateTime initialDate = selectedDate.isBefore(tomorrow) ? tomorrow : selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tomorrow,
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
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
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : appointmentTypes.isEmpty
              ? Center(
                  child: Text(
                    'Loading appointment types...',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : appointments.isEmpty
                  ? Center(
                      child: Text(
                        'No appointments found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: ListTile(
                            title: Text(appointments[index]["title"]!),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Service: ${appointments[index]["title"]}"),
                                Text("Date: ${appointments[index]["date"]}"),
                                Text("Time: ${appointments[index]["time"]}"),
                                Divider(
                                  thickness: 1,
                                  color: Colors.purple,
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigate to appointment details screen
                            },
                          ),
                        );
                      },
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SingleChildScrollView(
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          "New Appointment",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Divider(
                                          thickness: 3,
                                          color: Colors.purple,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          child: DropdownButtonFormField<String>(
                                            value: selectedAppointmentType,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedAppointmentType = newValue!;
                                              });
                                            },
                                            items: appointmentTypes.map<DropdownMenuItem<String>>(
                                              (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              },
                                            ).toList(),
                                            decoration: InputDecoration(
                                              labelText: 'Appointment Type',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  readOnly: true,
                                                  controller: TextEditingController(
                                                    text: "${selectedDate.toLocal()}".split(' ')[0],
                                                  ),
                                                  onTap: () async {
                                                    await _selectDate(context);
                                                    setState(() {
                                                      selectedDate = selectedDate;
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'Date',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: TextFormField(
                                                  readOnly: true,
                                                  controller: TextEditingController(
                                                    text: selectedTime.format(context),
                                                  ),
                                                  onTap: () async {
                                                    await _selectTime(context);
                                                    setState(() {
                                                      selectedTime = selectedTime;
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'Time',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _createAppointment();
                                          },
                                          child: Text('Create Appointment'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(Icons.add),
                    ),
    ),
  );
    
  }

}

