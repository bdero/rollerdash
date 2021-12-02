import 'dart:io';

import 'package:args/args.dart';

const defaultRollers = [
  "skia-flutter-autoroll",
  "clang-linux-flutter-engine",
  "clang-mac-flutter-engine",
  "dart-sdk-flutter-engine",
  "flutter-engine-flutter-autoroll",
  "flutter-plugins-flutter-autoroll",
  "fuchsia-linux-sdk-flutter-engine",
  "fuchsia-mac-sdk-flutter-engine",
  "clang-windows-flutter-engine",
];

enum RunMode {
  print,
  watch,
}

class Config {
  RunMode runMode = RunMode.print;
  int watchIntervalSeconds = 30;

  List<String> rollers = defaultRollers;

  static Config fromArgs(List<String> arguments) {
    final watchParser = ArgParser()
      ..addOption(
        'time',
        abbr: 't',
        help: 'The interval to wait between watch updates',
        valueHelp: 'seconds',
        defaultsTo: '30',
      );

    final parser = ArgParser()
      ..addCommand('watch', watchParser)
      ..addFlag('help',
          abbr: 'h', help: 'Print this help message.', negatable: false);

    void printUsage() {
      print('Usage: rollerdash [watch]\n');
      print('Fetch the status of Flutter\'s rollers.\n');
      print(parser.usage);
      print(watchParser.usage);
    }

    Config result = Config();
    ArgResults parsedArgs;
    try {
      parsedArgs = parser.parse(arguments);
    } on FormatException catch (e) {
      print('$e\n');
      printUsage();
      exit(64);
    }

    if (parsedArgs['help']) {
      printUsage();
      exit(0);
    }

    if (parsedArgs.command?.name == 'watch') {
      result.runMode = RunMode.watch;
      result.watchIntervalSeconds =
          int.tryParse(parsedArgs.command?['time']) ?? 30;
    }

    return result;
  }
}
