# rollerdash
A simple client for querying the Skia AutoRoll service.

![Summary screenshot](screenshots/summary.png)

## Usage

> **_NOTE:_** This tool uses ANSI escape codes and unicode glyphs. Output won't appear to be properly formatted in terminals that don't support one or both of these features.

1. Clone this repository.
1. `dart run bin/rollerdash.dart watch`

```
Usage: rollerdash [watch]

Fetch the status of Flutter's rollers.

-h, --help    Print this help message.
-t, --time=<seconds>    The interval to wait between watch updates
                        (defaults to "30")
```

## Developing

When making any changes to `schema.dart`, run `dart run build_runner build` to regenerate `schema.g.dart`.
