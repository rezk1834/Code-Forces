import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HomePage.dart';
import 'Service/api_service.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _handleController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await getInfo(_handleController.text);
      await getContests(_handleController.text);
      // await getStatus(_handleController.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(handle: _handleController.text),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid handle or failed to fetch data. Please try again.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _register() async {
    final Uri uri = Uri.parse('https://codeforces.com/register');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Please Check your internet connection';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Image.asset(
                "assets/icon.png",
                width: 120,
                height: 120,
              ),
              SizedBox(height: 40),
              Builder(
                builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  return Text(
                    'Welcome to Code Forces Helper',
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              SizedBox(height: 40),
              TextField(
                controller: _handleController,
                decoration: InputDecoration(
                  labelText: 'CodeForces Handle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _errorMessage,
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        side: BorderSide(width: 2, color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _register,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          'Register',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
