import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<void> clearCacheByKey(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Would you like to log out?"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  clearCacheByKey("cachedEmail");
                  Navigator.of(context).pop();
                },
                child: Text("Yes"),
              ),
            ],
          ),
        ),
      )
    );
    
  }

}
