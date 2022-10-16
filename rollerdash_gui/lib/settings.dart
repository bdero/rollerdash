import 'package:flutter/material.dart';
import 'package:rollerdash/config.dart' as rd_config;

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
