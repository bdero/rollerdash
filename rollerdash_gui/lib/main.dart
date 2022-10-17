import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rollerdash/fetch.dart' as rd_fetch;
import 'package:rollerdash/schema.dart';
import 'package:rollerdash_gui/settings.dart';
import 'package:rollerdash_gui/settings_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
            colorScheme: lightDynamic ??
                ColorScheme.fromSwatch(
                  primarySwatch: Colors.blue,
                  brightness: Brightness.light,
                ),
            useMaterial3: true
            //brightness: Brightness.dark,
            ),
        darkTheme: ThemeData(
            colorScheme: darkDynamic ??
                ColorScheme.fromSwatch(
                  primarySwatch: Colors.blue,
                  brightness: Brightness.dark,
                ),
            useMaterial3: true
            //brightness: Brightness.dark,
            ),
        themeMode: ThemeMode.system,
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
          );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rollerdash",
              textAlign: TextAlign.left,
            ),
            Text(
              "Last polled: ${lastUpdated?.toLocal() ?? "Never"}",
              style: TextStyle(
                  fontSize: 14, color: Theme.of(context).secondaryHeaderColor),
            ),
          ],
        ),
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
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final status in rollerStatuses) Roller(status: status),
          ],
        ),
      ),
    );
  }
}

class Roller extends StatelessWidget {
  const Roller({Key? key, required this.status}) : super(key: key);

  final StatusModel status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Material(
        color: Theme.of(context).dialogBackgroundColor,
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.all(Radius.circular(35)),
        child: ExpansionTile(
          shape: Border.all(width: 0, color: Colors.transparent),
          title: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.error_outline, color: Colors.red),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status.mini_status.roller_id),
                    Wrap(
                      spacing: 10,
                      children: const [
                        Chip(
                          visualDensity:
                              VisualDensity(horizontal: 0, vertical: -4),
                          avatar: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3,
                            ),
                          ),
                          label: Text(
                            "In Progress",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          backgroundColor: Colors.yellow,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                        Chip(
                          visualDensity:
                              VisualDensity(horizontal: 0, vertical: -4),
                          avatar: Icon(
                            Icons.rocket_launch_outlined,
                            color: Colors.black,
                          ),
                          label: Text(
                            "Running",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          backgroundColor: Colors.green,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                        Chip(
                          visualDensity:
                              VisualDensity(horizontal: 0, vertical: -4),
                          avatar: Icon(
                            Icons.commit_outlined,
                            color: Colors.black,
                          ),
                          label: Text(
                            "Behind 3 commits",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          backgroundColor: Colors.grey,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(
                      'https://autoroll.skia.org/r/${status.mini_status.roller_id}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw Exception("Unable to open URL: $url");
                  }
                },
                icon: const Icon(Icons.arrow_outward_rounded),
                label: const Text("View Roller"),
              ),
            ],
          ),
          subtitle: Container(
            alignment: Alignment.centerLeft,
          ),
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        width: 5,
                        color: Theme.of(context).scaffoldBackgroundColor)),
              ),
              child: Column(
                children: [
                  Container(child: Text(status.recent_rolls[0].result)),
                  Container(child: Text(status.mini_status.mode)),
                  Container(
                    child: Text(
                        'Behind: ${status.mini_status.num_behind} commit${status.mini_status.num_behind == 1 ? " " : "s"}'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
