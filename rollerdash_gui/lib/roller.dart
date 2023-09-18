import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:rollerdash/schema.dart';
import 'package:rollerdash_gui/roll_status_icon.dart';
import 'package:rollerdash_gui/roller_chip.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Roller extends StatefulWidget {
  const Roller({Key? key, required this.status}) : super(key: key);

  final StatusModel status;

  @override
  State<Roller> createState() => _RollerState();
}

class _RollerState extends State<Roller> {
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
          key: PageStorageKey(widget.status.mini_status.roller_id),
          shape: Border.all(width: 0, color: Colors.transparent),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12, 30),
                  child: RollStatusIcon(status: widget.status),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${widget.status.mini_status.child_name}   ( ${widget.status.mini_status.roller_id} )'),
                      Wrap(
                        spacing: 10,
                        children: [
                          RollModeChip(mode: widget.status.mini_status.mode),
                          if (widget.status.recent_rolls.isNotEmpty &&
                              widget.status.recent_rolls[0].result ==
                                  'IN_PROGRESS')
                            RollStatusChip(
                                status: widget.status.recent_rolls[0].result),
                          if (widget.status.mini_status.num_behind.toInt() > 0)
                            RollerChip(
                              avatar: const Icon(
                                Icons.commit_outlined,
                                color: Colors.black,
                              ),
                              label: Text(
                                "Behind ${widget.status.mini_status.num_behind} commit${widget.status.mini_status.num_behind == 1 ? " " : "s"}",
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
                        'https://autoroll.skia.org/r/${widget.status.mini_status.roller_id}');
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
                  for (final roll in widget.status.recent_rolls)
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
                                    var secondsSinceRollCreated = DateTime.now()
                                        .difference(
                                            DateTime.parse(roll.created))
                                        .inSeconds;
                                    var inProgress =
                                        roll.result == "IN_PROGRESS";
                                    var textColor = Color.lerp(
                                        Colors.white,
                                        inProgress ? Colors.red : Colors.grey,
                                        clampDouble(
                                            secondsSinceRollCreated.toDouble() /
                                                60.0 /
                                                60.0 /
                                                24.0,
                                            0,
                                            1))!;
                                    return Text(
                                      value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: textColor,
                                          fontWeight: inProgress
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                    );
                                  },
                                  date: DateTime.parse(roll.created),
                                  refreshRate: const Duration(minutes: 1),
                                ),
                              ),
                              // TODO(bdero): This should be SelectableText, but an obscure key-related error happens with the PageStorageKey is present on the ExpansionTile.
                              Text(
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
                              Text(
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
                                final url = Uri.parse(
                                    widget.status.issue_url_base + roll.id);
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
