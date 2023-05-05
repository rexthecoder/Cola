## cola
---

## Getting Started 🚀

If the CLI application is available on [pub](https://pub.dev), activate globally via:

```sh
dart pub global activate cola
```

Or locally via:

```sh
dart pub global activate --source=path <path to this package>
```

## Usage

```sh
# Send to
$  cola push --bundle-identifier="co.exmple.flutter" --title="Rexford" --body="What if he dies"

# Show CLI version
$ cola --version

# Show usage help
$ cola --help
```

## Running Tests with coverage 🧪

To run all unit tests use the following command:

```sh
$ dart pub global activate coverage 1.2.0
$ dart test --coverage=coverage
$ dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov)
.

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT