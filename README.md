# rollerdash
A simple client for querying the Skia AutoRoll service.

![Summary screenshot](screenshots/summary.png)

## Quick start
```bash
git clone https://github.com/bdero/rollerdash.git
cd rollerdash
flutter pub get
dart run bin/rollerdash.dart watch
```

## Usage

> **_NOTE:_** This tool uses ANSI escape codes and unicode glyphs. Output won't appear to be properly formatted in terminals that don't support one or both of these features.

```
Usage: rollerdash [watch]

Fetch the status of Flutter's rollers.

-h, --help    Print this help message.
-t, --time=<seconds>    The interval to wait between watch updates
                        (defaults to "30")
```

## Developing

When making any changes to `schema.dart`, run `dart run build_runner build` to regenerate `schema.g.dart`.
