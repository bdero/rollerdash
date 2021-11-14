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
];

enum RunMode {
  print,
  watch,
}

class Config {
  RunMode runMode = RunMode.print;
  int watchIntervalSeconds = 10;

  List<String> rollers = defaultRollers;

  static Config fromArgs(List<String> arguments) {
    final parser = ArgParser()
      ..addCommand(
          'watch',
          ArgParser()
            ..addOption(
              'time',
              abbr: 't',
              help: 'The interval to wait between watch updates',
              valueHelp: 'seconds',
              defaultsTo: '10',
            ));

    Config result = Config();

    ArgResults parsedArgs = parser.parse(arguments);
    if (parsedArgs.command?.name == 'watch') {
      result.runMode = RunMode.watch;
      result.watchIntervalSeconds =
          int.tryParse(parsedArgs.command?['time']) ?? 10;
    }

    return result;
  }
}
