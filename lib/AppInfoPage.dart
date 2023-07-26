import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Information'),
      ),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(1.0), // Add padding around the logo row
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAppLogo(), // Actual image 1
                        SizedBox(width: 20), // Add space between the logos
                        _buildContributorLogo(), // Actual image 2
                      ],
                    ),
                  ),
                  _buildInfoRow(
                    context,
                    'Project Title:',
                    'CLINIC MANAGEMENT SYSTEM USING CBQ AND LINKED LIST @ MOBILE APPLICATION DEVELOPMENT FOR CLINIC MANAGEMENT SYSTEM USING CBQ AND LINKEDLIST',
                  ),
                  SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    'Contributors:',
                    'MUHAMAD RAHMAT MUSTAFA;UMMU FATIHAH MOHD BAHRIN;HASIAH MOHAMED @ OMAR (Ts. Dr.)',
                  ),
                  SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    'Summary:',
                    'This application was developed as per the requirements for the course CSP650 (Final Year Project) in the program Bachelors of Computer Science (Hons.) Mobile Computer (CS270) at Universiti Teknologi MARA (UiTM) Cawangan Terengganu Kampus Kuala Terengganu.',
                  ),
                  SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    'Session:',
                    'October 2022 - February 2023 & March - August 2023',
                  ),
                  SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    'GitHub:',
                    'MAISON (Patient\'s Side): [link git app];MAISON (Personnels\' Side): [link git web]',
                  ),
                  SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    'Remarks:',
                    'The Personnels\'s side of MAISON is accessible at [link]',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8), // Add vertical padding
      width: 150, // Set the desired width
      height: 150, // Set the desired height
      child: Image.asset('assets/maison-logo-no-line.png'),
    );
  }

  Widget _buildContributorLogo() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8), // Add vertical padding
      width: 450, // Set the desired width
      height: 450, // Set the desired height
      child: Image.asset('assets/uitmkt-logo.png'),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String description) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8, // Adjust the width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: description.split(';').length,
            itemBuilder: (context, index) {
              String name = description.split(';')[index].trim();
              return Padding(
                padding: EdgeInsets.only(top: 8), // Add desired top padding
                child: Text(
                  name,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.justify, // Justify the text
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
