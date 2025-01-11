import 'package:expense_tracker/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? appVersionMsg;
  bool isConnected = true;

  Future<void> pingWebsite() async {
    try {
      final response = await http
          .get(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        setState(() {
          isConnected = true;
        });
      } else {
        setState(() {
          isConnected = false;
        });
      }
    } catch (e) {
      setState(() {
        isConnected = false;
      });
    }
  }

  Future<void> getAppLatestVersion() async {
    appVersionMsg = null;

    try {
      final response = await http.get(
        Uri.parse('$API_URL/mobile-app-version'),
        headers: {'Accept': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (responseData['status'] != 'success') {
        setState(() {
          appVersionMsg = 'There was an error. Please try again later.';
        });
      } else if (responseData['status'] == 'success') {
        if (responseData['version'] != '1.0.0') {
          setState(() {
            appVersionMsg = 'Please update the app to the latest version.';
          });
        }
      }
    } catch (e) {
      setState(() {
        appVersionMsg = 'There was an error. Please try again later.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //  ping website to test internet connectivity
    pingWebsite();
    // get app latest version from the server
    getAppLatestVersion();
  }

  @override
  Widget build(BuildContext context) {
    return appVersionMsg != null || !isConnected
        ? (!isConnected
            ? Text('Please check your internet connection.')
            : Text(
                appVersionMsg!,
                textAlign: TextAlign.center,
              ))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '♥ Welcome ♥',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Thank you for choosing our personal expense tracking app!',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Our app is designed to help you manage your daily expenses easily and effectively, allowing you to organize your budget in a smart and hassle-free way.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'By tracking your expenses, you’ll gain a clear and comprehensive understanding of your financial habits, enabling you to make better financial decisions.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Simply record your daily expenses for 90 days to calculate your average spending per day, month, and year for better financial planning.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                ' You must be connected to the internet to use this app.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'This app is designed & developed & published by Ali Hussein, a full stack web and mobile app developer.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'You can reach out using the developer\'s website => https://aly-h.com',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Thank you again, and we wish you a fantastic experience using the app!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
  }
}
