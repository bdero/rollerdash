import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rollerdash/fetch.dart' as rd_fetch;
import 'package:rollerdash/schema.dart';
import 'package:rollerdash_gui/settings.dart';
import 'package:rollerdash_gui/settings_widget.dart';

void main() {
  runApp(const RollerdashApp());
}

class RollerdashApp extends StatelessWidget {
  const RollerdashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RollerdashSettingsWrapper(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rollerdash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MainPage(),
    ));
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool refreshing = false;

  List<StatusModel> rollerModels = [];
  DateTime? lastUpdated;

  Timer? updateTimer;
  int currentWatchIntervalSeconds = 30;

  @override
  void initState() {
    super.initState();

    // The roller data is pulled from the RollerdashSettings InheritedWidget, so
    // `fetchRollerData` needs to be called after `initState` completes.
    Future.delayed(Duration.zero, () {
      fetchRollerData();

      var settings = RollerdashSettings.of(context);
      settings.subscribe((value) {
        if (value.watchIntervalSeconds != currentWatchIntervalSeconds) {
          resetUpdateTimer();
        }
      });
    });
  }

  /// Resets the new update timer to match the global config. Cancel's the
  /// current update timer if it was already active.
  ///
  /// This is called when `fetchRollerData` completes to start a new timer for
  /// the next fetch. It's also called if the interval setting has changed.
  void resetUpdateTimer() {
    if (updateTimer != null && updateTimer!.isActive) {
      updateTimer!.cancel();
    }

    currentWatchIntervalSeconds =
        RollerdashSettings.of(context).config.watchIntervalSeconds;

    updateTimer = Timer(Duration(seconds: currentWatchIntervalSeconds),
        () => fetchRollerData());
  }

  void fetchRollerData() {
    if (refreshing) return;

    setState(() {
      refreshing = true;
    });

    rd_fetch
        .getAllStatuses(RollerdashSettings.of(context).config.rollers)
        .then((value) => setState(() {
              refreshing = false;

              rollerModels = value;
              lastUpdated = DateTime.now();

              resetUpdateTimer();
            }));
  }

  @override
  Widget build(BuildContext context) {
    var config = RollerdashSettings.of(context).config;
    if (currentWatchIntervalSeconds != config.watchIntervalSeconds) {
      resetUpdateTimer();
    }

    var refreshButton = refreshing
        ? Container(
            width: 15,
            height: 15,
            margin: const EdgeInsets.only(right: 12),
            child: const CircularProgressIndicator(),
          )
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
      endDrawer: const Drawer(child: SettingsWidget()),
      body: Text(lastUpdated?.toString() ?? "Never"),
    );
  }
}