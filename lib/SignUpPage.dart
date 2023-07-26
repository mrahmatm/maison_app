import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  static const String routeName = '/signup';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController icNumberController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  bool isICNumberValid = false;
  bool isPhoneNumberValid = false;
  bool isButtonEnabled = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    icNumberController.addListener(validateFields);
    fullNameController.addListener(validateFields);
    emailController.addListener(validateFields);
    phoneNumberController.addListener(validateFields);
  }

  @override
  void dispose() {
    icNumberController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void validateFields() {
    setState(() {
      final icNumber = icNumberController.text;
      final fullName = fullNameController.text;
      final email = emailController.text;
      final phoneNumber = phoneNumberController.text;

      final icNumberPattern = RegExp(r'^\d{6}-\d{2}-\d{4}$');
      isICNumberValid = icNumberPattern.hasMatch(icNumber);
      final isFullNameValid = fullName.isNotEmpty;
      final isEmailValid = email.isNotEmpty;
      isPhoneNumberValid = phoneNumber.length >= 10;

      isButtonEnabled =
          isICNumberValid && isFullNameValid && isEmailValid && isPhoneNumberValid;
    });
  }

bool isLoading = false; // Replace this with your actual logic for isLoading

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Sign Up'),
    ),
    body: SafeArea(
      child: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: icNumberController,
                      decoration: InputDecoration(
                        labelText: 'IC Number',
                        errorText: isICNumberValid ? null : 'Invalid IC Number (e.g. 000923-11-2355)',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]'))
                      ],
                    ),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        errorText: isPhoneNumberValid ? null : 'Phone Number should be at least 10 digits long',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\+]'))
                      ],
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: isButtonEnabled ? signUp : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(300, 50),
                      ),
                      child: Text('Sign Up'),
                    ),
                  ],
                ),
              ),
      ),
    ),
  );
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

  void signUp() async {
    setState(() {
      isLoading = true;
    });

    final icNumber = icNumberController.text;
    final fullName = fullNameController.text;
    final email = emailController.text;
    final phoneNumber = phoneNumberController.text;

    //print('IC Number: $icNumber');
    //print('Full Name: $fullName');
    //print('Email: $email');
    //print('Phone Number: $phoneNumber');

    final url = 'https://maison-client.000webhostapp.com/mobile%20request.php'; // Replace with your actual URL

  // Show the loading dialog before making the HTTP request
    //showLoadingDialog(context, "Logging in...");

  try{
    final response = await http.post(
      Uri.parse(url),
      body: {
        'method': 'signUp',
        'patient_ICNum': icNumber,
        'patient_name': fullName,
        'patient_email': email,
        'patient_phoneNum': phoneNumber,
      },
    );
    //print("attempting request!");
    

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      print("response received 200!");
      final result = response.body;
      print(result);
      // Dismiss the loading dialog after receiving the response
      
      if (result == '1') {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up successful!'),
          ),
        );
      } else if (result == '-1') {
        // Failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed!'),
          ),
        );
      } else if (result == '0') {
        // Failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email or IC Number Already Registered!'),
          ),
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please recheck all fields!'),
          ),
        );
      }
      //Navigator.of(context).pop();
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred while signing up!'),
        ),
      );
    }
  }catch(e){
    setState(() {
        isLoading = false;
      });
    print("Error: $e");
    // Dismiss the loading dialog after receiving the response
    Navigator.of(context).pop();
  }

  
    
  }
}
