import 'package:flutter/material.dart';
import 'practice_screen.dart';

void main() {
  runApp(const WimHofApp());
}

class WimHofApp extends StatelessWidget {
  const WimHofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wim Hof Breathing',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: PracticeScreen());
  }
}
