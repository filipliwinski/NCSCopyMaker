# Changelog

## Unreleased

- Added version number to the script header, displayed on startup.
- Introduced this changelog file to track release history.
- Fixed folder year at year boundary.
- Script now exits cleanly when no past or future deadline is found.

## 2024-09-01 — 0.6.0

- Added validation of deadlines; script now throws if no past deadline exists in the config.
- General script hardening; set `$ErrorActionPreference = "Stop"` to make all errors terminating.

## 2023-03-22 — 0.5.2

- Fixed issue with getting repositories from the provided location.

## 2021-11-24 — 0.5.1

- Fixed issue with overriding `backInTimeInWeeks` when passed as a script argument.
- Fixed debug mode output folder selection (typo and inverted condition introduced in 0.5.0).

## 2021-10-26 — 0.5.0

- Added `backInTimeInWeeks` as a script argument.
- Added support for debug mode.

## 2021-05-25 — 0.4.0

- Added support for specifying a path to repositories.

## 2021-01-22 — 0.3.1

- Fixed invalid start date and folder name generation.
- Replaced billing month calculation: now derived from the next future deadline instead of the past deadline.

## 2020-12-20 — 0.3.0

- Added zip compression for output.
- General script bugfixes; removed sample `config.json` from the repository (configuration schema documented in README instead).

## 2020-10-30 — 0.2.0

- Added `outputDirectory` and billing month support.
- Added output directory configuration option.
- Fixed start and end dates to begin at midnight.

## 2020-10-26 — 0.1.0

- Initial release.
