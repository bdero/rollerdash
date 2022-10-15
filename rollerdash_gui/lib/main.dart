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

class RollerdashSettings extends InheritedWidget {
  const RollerdashSettings(
      {super.key,
      required super.child,
      required this.config,
      required this.publishConfig,
      required this.subscribe});

  final rd_config.Config config;
  final ValueChanged<rd_config.Config> publishConfig;
  final Function(ValueChanged<rd_config.Config> callback) subscribe;

  static RollerdashSettings of(BuildContext context) {
    final RollerdashSettings? result =
        context.dependOnInheritedWidgetOfExactType<RollerdashSettings>();
    assert(result != null, 'No RollerdashSettings found in context.');
    return result!;
  }

  @override
  bool updateShouldNotify(RollerdashSettings oldWidget) =>
      config.watchIntervalSeconds != oldWidget.config.watchIntervalSeconds ||
      config.rollers != oldWidget.config.rollers;
}

class RollerdashSettingsWrapper extends StatefulWidget {
  const RollerdashSettingsWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<RollerdashSettingsWrapper> createState() =>
      _RollerdashSettingsWrapperState();
}

class _RollerdashSettingsWrapperState extends State<RollerdashSettingsWrapper> {
  rd_config.Config config = rd_config.Config();
  List<ValueChanged<rd_config.Config>> configSubscriptions = [];

  void publishConfig(rd_config.Config config_) {
    setState(() {
      config = config_;
      for (var callback in configSubscriptions) {
        callback(config_);
      }
    });
  }

  void subscribe(ValueChanged<rd_config.Config> callback) {
    configSubscriptions.add(callback);
  }

  @override
  Widget build(BuildContext context) {
    return RollerdashSettings(
      config: config,
      publishConfig: publishConfig,
      subscribe: subscribe,
      child: widget.child,
    );
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
      body: SelectionArea(child: Text(lastUpdated?.toString() ?? "Never")),
      endDrawer: const Drawer(child: SettingsWidget()),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(width: 0)),
              child: const Text(
                "Settings",
                style: TextStyle(fontSize: 24),
              )),
          ListTile(
            title: DropdownButtonFormField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.timer),
                  labelText: "Refresh interval",
                  filled: true),
              items: const [
                DropdownMenuItem(value: 5, child: Text("5 seconds")),
                DropdownMenuItem(value: 10, child: Text("10 seconds")),
                DropdownMenuItem(value: 30, child: Text("30 seconds")),
                DropdownMenuItem(value: 60, child: Text("1 minute")),
                DropdownMenuItem(value: 300, child: Text("5 minutes")),
                DropdownMenuItem(value: 600, child: Text("10 minutes")),
              ],
              onChanged: (value) {
                var settings = RollerdashSettings.of(context);
                settings.config.watchIntervalSeconds = value!;
                settings.publishConfig(settings.config);
              },
              value: RollerdashSettings.of(context).config.watchIntervalSeconds,
            ),
          ),
        ],
      ),
    );
  }
}
