import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rollerdash/config.dart' as rd_config;
import 'package:rollerdash/fetch.dart' as rd_fetch;
import 'package:rollerdash/schema.dart';

void main() {
  runApp(const RollerdashApp());
}

class RollerdashApp extends StatelessWidget {
  const RollerdashApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rollerdash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
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
  final rd_config.Config config = rd_config.Config();

  bool refreshing = false;

  List<StatusModel> rollerModels = [];
  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    fetchRollerData();
  }

  void fetchRollerData() {
    if (refreshing) return;

    setState(() {
      refreshing = true;
    });

    rd_fetch.getAllStatuses(config.rollers).then((value) => setState(() {
          refreshing = false;

          rollerModels = value;
          lastUpdated = DateTime.now();

          Timer(Duration(seconds: config.watchIntervalSeconds),
              () => fetchRollerData());
        }));
  }

  @override
  Widget build(BuildContext context) {
    var refreshButton = refreshing
        ? const CircularProgressIndicator()
        : IconButton(
            onPressed: () => fetchRollerData(),
            icon: const Icon(Icons.refresh),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rollerdash"),
        actions: [
          refreshButton,
          Builder(builder: (context) {
            return IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(Icons.settings));
          })
        ],
      ),
      body: SelectionArea(child: Text(lastUpdated?.toString() ?? "Never")),
      endDrawer: Drawer(child: SettingsWidget()),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  int refreshInterval = 5;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        children: [
          const Text("Refresh interval"),
          DropdownButton(
            items: const [
              DropdownMenuItem(value: 5, child: Text("5 seconds")),
              DropdownMenuItem(value: 10, child: Text("10 seconds")),
              DropdownMenuItem(value: 30, child: Text("30 sconds")),
              DropdownMenuItem(value: 60, child: Text("1 minute")),
              DropdownMenuItem(value: 300, child: Text("5 minutes")),
            ],
            onChanged: (value) => setState(() {
              refreshInterval = value!;
            }),
            value: refreshInterval,
          ),
        ],
      ),
    );
  }
}
