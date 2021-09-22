import 'package:args/args.dart';

class Config {
  static Config fromArgs(List<String> arguments) {
    final parser = ArgParser()..addFlag('verbose', negatable: false, abbr: 'v');
    ArgResults parsedArgs = parser.parse(arguments);

    Config result = Config()..verbose = parsedArgs['verbose'];
    return result;
  }

  bool verbose = false;
}
