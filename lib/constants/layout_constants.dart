import 'package:expense_tracker/screens/expense/expense.dart';
import 'package:expense_tracker/screens/home/home.dart';
import 'package:expense_tracker/screens/login/login.dart';
import 'package:expense_tracker/screens/profile/profile.dart';
import 'package:expense_tracker/screens/register/register.dart';
import 'package:flutter/material.dart';

const Map<String, dynamic> home = {
  'label': 'Home',
  'icon': Icon(Icons.home_outlined),
  'widget': Home()
};

const Map<String, List<Map<String, dynamic>>> screenInfo = {
  'guest': [
    home,
    {
      'label': 'Login',
      'icon': Icon(Icons.login),
      'widget': Login(),
    },
    {
      'label': 'Register',
      'icon': Icon(Icons.app_registration_outlined),
      'widget': Register(),
    },
  ],
  'auth': [
    home,
    {
      'label': 'Expense',
      'icon': Icon(Icons.attach_money_outlined),
      'widget': Expense(),
    },
    {
      'label': 'Profile',
      'icon': Icon(Icons.person_outline),
      'widget': Profile(),
    },
  ],
};

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromARGB(255, 127, 205, 250),
  onPrimary: Colors.white,
  secondary: Color.fromARGB(255, 221, 235, 247),
  onSecondary: Colors.white,
  error: Colors.red,
  onError: Colors.white,
  background: Colors.white,
  onBackground: Colors.black,
  surface: Color.fromARGB(255, 237, 237, 237),
  onSurface: Colors.black,
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color.fromARGB(255, 24, 5, 90),
  onPrimary: Colors.black,
  secondary: Color.fromRGBO(84, 79, 173, 1),
  onSecondary: Colors.black,
  error: Colors.red,
  onError: Colors.black,
  background: Colors.black,
  onBackground: Colors.white,
  surface: Color.fromARGB(255, 109, 109, 109),
  onSurface: Colors.white,
);

final lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  useMaterial3: true, // Optional: Use Material 3 design
  appBarTheme: AppBarTheme(
    backgroundColor: lightColorScheme.primary,
    foregroundColor: lightColorScheme.onPrimary,
  ),
);

final darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  useMaterial3: true, // Optional: Use Material 3 design
  appBarTheme: AppBarTheme(
    backgroundColor: darkColorScheme.primary,
    foregroundColor: darkColorScheme.onPrimary,
  ),
);
