import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rollerdash/fetch.dart' as rd_fetch;
import 'package:rollerdash/schema.dart';
import 'package:rollerdash_gui/settings.dart';
import 'package:rollerdash_gui/settings_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago_flutter/timeago_flutter.dart';
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
            tooltip: 'Refresh',
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
                      fontSize: 14,
                      color: Theme.of(context).secondaryHeaderColor),
                ),
                if (lastUpdated != null)
                  Timeago(
                    builder: (context, value) {
                      return Text(
                        value,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).secondaryHeaderColor),
                      );
                    },
                    date: lastUpdated!,
                    refreshRate: const Duration(seconds: 1),
                  ),
                Text(
                  '.',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).secondaryHeaderColor),
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

class RollerChip extends StatelessWidget {
  const RollerChip(
      {Key? key, required this.label, this.avatar, this.backgroundColor})
      : super(key: key);

  final Widget? avatar;
  final Widget label;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      avatar: avatar,
      label: label,
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
    );
  }
}

class RollStatusChip extends StatelessWidget {
  const RollStatusChip({Key? key, required this.status}) : super(key: key);

  final String status;

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color backgroundColor;
    Widget avatar;
    switch (status) {
      case 'IN_PROGRESS':
        statusText = 'In Progress';
        backgroundColor = Colors.yellow;
        avatar = const SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 3,
          ),
        );
        break;
      case 'SUCCESS':
        statusText = 'Success';
        backgroundColor = Colors.green;
        avatar = const Icon(
          Icons.check_outlined,
          color: Colors.black,
        );
        break;
      default: // FAILURE
        statusText = 'Failure';
        backgroundColor = Colors.red;
        avatar = const Icon(
          Icons.error_outline,
          color: Colors.black,
        );
        break;
    }

    return RollerChip(
      avatar: avatar,
      label: Text(
        statusText,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

class RollModeChip extends StatelessWidget {
  const RollModeChip({Key? key, required this.mode}) : super(key: key);

  final String mode;

  @override
  Widget build(BuildContext context) {
    String modeText;
    Color backgroundColor;
    IconData icon;
    switch (mode) {
      case 'RUNNING':
        modeText = 'Running';
        backgroundColor = Colors.green;
        icon = Icons.rocket_launch_outlined;
        break;
      default: // STOPPED
        modeText = 'Stopped';
        backgroundColor = Colors.red;
        icon = Icons.pause_outlined;
        break;
    }

    return RollerChip(
      avatar: Icon(
        icon,
        color: Colors.black,
      ),
      label: Text(
        modeText,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

/// Displays an icon indicating whether the last completed roll was successful
/// or not.
class RollStatusIcon extends StatelessWidget {
  const RollStatusIcon({Key? key, required this.status}) : super(key: key);

  final StatusModel status;

  @override
  Widget build(BuildContext context) {
    // Find the first roll entry that isn't in-progress.
    try {
      final roll = status.recent_rolls
          .firstWhere((roll) => roll.result != 'IN_PROGRESS');
      switch (roll.result) {
        case 'SUCCESS':
          return Tooltip(
            message:
                'Last success: ${timeago.format(DateTime.parse(roll.created))}',
            child: const Icon(
              Icons.check_outlined,
              color: Colors.green,
            ),
          );
        case 'FAILURE':
          return Tooltip(
            message:
                'Last failure: ${timeago.format(DateTime.parse(roll.created))}',
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          );
        default:
          debugPrint(
              'Unexpected roll status for ${status.mini_status.roller_id}: ${roll.result}');
          break;
      }
    } on StateError {
      debugPrint(
          'No completed roll found for ${status.mini_status.roller_id}.');
    }

    return const Tooltip(
      message: 'This roller is in an inknown state!',
      child: Icon(
        Icons.question_mark,
        color: Colors.yellow,
      ),
    );
  }
}

class Roller extends StatelessWidget {
  const Roller({Key? key, required this.status}) : super(key: key);

  final StatusModel status;

  @override
  Widget build(BuildContext context) {
    final separatorHSL =
        HSLColor.fromColor(Theme.of(context).dialogBackgroundColor);
    final headerSeparatorColor =
        separatorHSL.withLightness(separatorHSL.lightness + 0.03).toColor();

    return Container(
      margin: const EdgeInsets.all(5),
      child: Material(
        color: Theme.of(context).dialogBackgroundColor,
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: ExpansionTile(
          shape: Border.all(width: 0, color: Colors.transparent),
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: RollStatusIcon(status: status),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${status.mini_status.child_name}   ( ${status.mini_status.roller_id} )'),
                    Wrap(
                      spacing: 10,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 118,
                          child: RollStatusChip(
                              status: status.recent_rolls[0].result),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 118,
                          child: RollModeChip(mode: status.mini_status.mode),
                        ),
                        RollerChip(
                          avatar: const Icon(
                            Icons.commit_outlined,
                            color: Colors.black,
                          ),
                          label: Text(
                            "Behind ${status.mini_status.num_behind} commit${status.mini_status.num_behind == 1 ? " " : "s"}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                          ),
                          backgroundColor: Colors.grey,
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
                    width: 2,
                    color: headerSeparatorColor,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(52, 5, 52, 5),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(118), // Status
                  2: IntrinsicColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  for (final roll in status.recent_rolls)
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: RollStatusChip(
                              status: roll.result,
                            ),
                          ),
                        ),
                        TableCell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 170,
                                padding: const EdgeInsets.fromLTRB(0, 0, 60, 2),
                                child: Timeago(
                                  builder: (context, value) {
                                    return Text(
                                      value,
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                  date: DateTime.parse(roll.created),
                                  refreshRate: const Duration(minutes: 1),
                                ),
                              ),
                              SelectableText(
                                roll.rolling_from_hash.substring(0, 10),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontFamilyFallback: ['Courier'],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.forward_outlined),
                              ),
                              SelectableText(
                                roll.rolling_to_hash.substring(0, 10),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontFamilyFallback: ['Courier'],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final url =
                                    Uri.parse(status.issue_url_base + roll.id);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  throw Exception("Unable to open URL: $url");
                                }
                              },
                              icon: const Icon(Icons.arrow_outward_rounded),
                              label: Text('PR ${roll.id}'),
                            ),
                          ),
                        ),
                      ],
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
