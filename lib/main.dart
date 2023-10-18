import 'package:flutter/material.dart';
import 'package:teamformation/home_screen.dart'; // Import the UserListScreen from homescreen.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserListScreen(), // Use the UserListScreen from homescreen.dart
    );
  }
}
