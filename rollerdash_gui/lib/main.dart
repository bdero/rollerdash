import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rollerdash/fetch.dart' as rd_fetch;
import 'package:rollerdash/schema.dart';
import 'package:rollerdash_gui/roller.dart';
import 'package:rollerdash_gui/settings.dart';
import 'package:rollerdash_gui/settings_widget.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

void main() {
  runApp(const RollerdashApp());
}

class RollerdashApp extends StatelessWidget {
  const RollerdashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RollerdashSettingsWrapper(
        child: DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rollerdash',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        home: const MainPage(),
      );
    }));
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool refreshing = false;

  List<StatusModel> rollerStatuses = [];
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

    Future<List<StatusModel>> fetchRollers() {
      return rd_fetch
          .getAllStatuses(RollerdashSettings.of(context).config.rollers)
          .onError((error, stackTrace) {
        final errorMessage = "$error\n\n$stackTrace";
        debugPrint(errorMessage);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 10),
          content: SelectableText(errorMessage),
          action: SnackBarAction(
              label: "Copy",
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: errorMessage))),
        ));

        return fetchRollers();
      });
    }

    fetchRollers().then((value) => setState(() {
          refreshing = false;

          rollerStatuses = value;
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
            tooltip: 'Poll rollers',
          );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rollerdash',
              textAlign: TextAlign.left,
            ),
            Row(
              children: [
                Text(
                  'Last polled ',
                  style: TextStyle(
                      fontSize: 14, color: Theme.of(context).hintColor),
                ),
                if (lastUpdated != null)
                  Timeago(
                    builder: (context, value) {
                      return Text(
                        value,
                        style: TextStyle(
                            fontSize: 14, color: Theme.of(context).hintColor),
                      );
                    },
                    date: lastUpdated!,
                    refreshRate: const Duration(seconds: 1),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          refreshButton,
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
            );
          })
        ],
      ),
      endDrawer: const Drawer(child: SettingsWidget()),
      body: Container(
        alignment: Alignment.center,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            for (final status in rollerStatuses)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Roller(status: status),
              ),
          ],
        ),
      ),
    );
  }
}
