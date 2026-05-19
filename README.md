# Vedla CLI for Flutter

[![License: MIT][license_badge]][license_link] [![Status: early development][status_badge]](https://gitlab.com/vedla/fox_sdk)

Fox SDK provides a small set of tools and commands to build, run Flutter apps
and manage CLI updates, with first-class support for monorepos and common
run-time options (flavors, targets, platforms).

### ⚠️ EARLY DEVELOPMENT — NOT STABLE

> ***WARNING***: This project is in early development and is NOT stable. APIs,
> commands, and behavior may change without notice. It's use on production
> products is not recommended.

---

## Features

- Run a Flutter app from the current directory, an explicit path, or a monorepo project folder
- Resolve entrypoints by flavor (e.g. `lib/main_development.dart`)
- Platform selection (android, ios, web, macos, windows, linux, desktop)
- Self-update command to keep the CLI current

## Installation

Install globally from pub:

```bash
dart pub global activate fox_sdk
```

Install directly from the Git repository:

```bash
dart pub global activate --source=git https://gitlab.com/vedla/fox_sdk.git
```

Or activate from a local checkout:

```bash
dart pub global activate --source=path /path/to/fox_sdk
```

Run `fox --help` for general help or `fox <command> --help`
for command-specific options.

## Usage

### General form

```bash
fox <command> [options]
```

### Common commands

- `run` — Runs a Flutter app from the current directory, a monorepo project, or an explicit project path.

**Run Options:**

- `-p`, `--project`  : Project name when running from a monorepo
- `--path`           : Explicit project directory to run
- `--target`         : Entrypoint file (e.g. `lib/main_dev.dart`)
- `--flavor`         : Build flavor (e.g. `development`)
- `--profile`        : Build profile: `debug`, `profile`, or `release`
- `--platform`       : Target platform (`android`, `ios`, `web`, `macos`,`windows`, `linux`, `desktop`)

#### Examples

```bash
# Run the Flutter app in the current directory
fox run

# Run a project by path
fox run --path ../my_app

# Run a monorepo project by name
fox run --project my_app

# Run with a flavor and explicit target
fox run --flavor development --target lib/main_development.dart

# Run on iOS
fox run --platform ios
```

- `update` — Update the CLI to the latest published version.

```bash
fox update
```

## Projects that use fox_sdk

- [Furlab Studio](https://gitlab.com/furlab/thestudio)
- [FoxUI for Flutter](https://gitlab.com/vedla/foxui)

## Contributing

Contributions and issues are welcome. Please open issues or merge requests on
the repository. Run the linters and tests before submitting changes.

## License

This project is released under the MIT License.

## Repository Information

GitHub is used for public releases, discussions, and community contributions.

Development infrastructure, CI/CD, and internal tooling are managed through [GitLab](https://gitlab.com/vedla/fox_sdk)

---

Made with <img src="https://upload.wikimedia.org/wikipedia/commons/2/2c/Maple_leaf_transparent.png" width="20" alt="Canadian maple leaf"> in Canada.

<sub> Furlab Studio, Vedla Creative & TheFoxSDK - © 2026 Vedla Creative
Maple leaf from Wikimedia Commons. Original upload by Denelson83, updated by MapGrid (Public Domain).</sub>

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[status_badge]: https://img.shields.io/badge/status-early%20development-yellow.svg
