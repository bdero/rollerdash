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

class Config {
  bool verbose = false;
  List<String> rollers = defaultRollers;

  static Config fromArgs(List<String> arguments) {
    final parser = ArgParser()..addFlag('verbose', negatable: false, abbr: 'v');
    ArgResults parsedArgs = parser.parse(arguments);

    Config result = Config()..verbose = parsedArgs['verbose'];
    return result;
  }
}
