import 'dart:io';

import 'package:args/args.dart';

const defaultRollers = [
  "skia-flutter-autoroll",
  "clang-flutter-engine",
  "dart-sdk-flutter-engine",
  "flutter-engine-flutter-autoroll",
  "fuchsia-linux-sdk-flutter-engine",
  "fuchsia-mac-sdk-flutter-engine",
  "angle-flutter-engine",
];

enum RunMode {
  print,
  watch,
  dump,
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
        help:
            'The interval to wait between watch updates. Only applies to the `watch` command.',
        valueHelp: 'seconds',
        defaultsTo: '30',
      );

    final parser = ArgParser()
      ..addCommand('watch', watchParser)
      ..addCommand('dump')
      ..addFlag('help',
          abbr: 'h', help: 'Print this help message.', negatable: false);

    void printUsage() {
      print('\nUsage: rollerdash [WATCH|DUMP]\n');
      print('Fetch the status of Flutter\'s rollers.\n');
      print(
          '  WATCH: Run the program indefinitely, updating the status at a set interval.');
      print(
          '   DUMP: Dump the data returned by the roller RPCs to stdout and exit.\n');
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

    switch (parsedArgs.command?.name) {
      case 'watch':
        result.runMode = RunMode.watch;
        result.watchIntervalSeconds =
            int.tryParse(parsedArgs.command?['time']) ?? 30;
        break;
      case 'dump':
        result.runMode = RunMode.dump;
        break;
    }

    return result;
  }
}
