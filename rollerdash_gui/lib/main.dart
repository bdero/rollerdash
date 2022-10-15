import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rollerdash/fetch.dart' as rd_fetch;

void main() {
  runApp(const RollerdashApp());
}

class RollerdashApp extends StatelessWidget {
  const RollerdashApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rollerdash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void fetchRollerData() {
    setState(() {
      Timer(const Duration(seconds: 1), () => fetchRollerData());
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRollerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(child: Text(DateTime.now().toString())),
    );
  }
}
