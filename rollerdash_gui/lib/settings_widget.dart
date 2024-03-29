import 'package:flutter/material.dart';
import 'package:rollerdash_gui/settings.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ListTile(
            title: Text(
          "Settings",
          style: TextStyle(fontSize: 16),
        )),
        ListTile(
          title: DropdownButtonFormField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.timer_outlined),
              labelText: "Refresh interval",
            ),
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
    );
  }
}
