import 'package:flutter/material.dart';
import 'package:suni_pal_app/pages/homepage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 222, 250, 254),
        appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 222, 250, 254),
       ),
      ),
      home: Homepage(),
    );
  }
}