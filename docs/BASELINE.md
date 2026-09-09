# JARVIS Phase 1 baseline

**Captured:** 2026-09-08  
**Workspace:** `abivarman1729-add-logo-assets`

## Environment

| Component | Result |
|---|---|
| Flutter | 3.47.2 stable |
| Dart | 3.13.2 |
| Android SDK | 37.0.0 |
| Java | OpenJDK 17.0.20 |
| Host | Windows 11 25H2 |
| Connected targets | Windows desktop, Chrome, Edge |
| Declared SDK constraints | Dart `>=3.4.0 <4.0.0`, Flutter `>=3.24.0` |

`flutter doctor -v` reported no environment issues, and Android licenses were accepted.

## Command results

### Passing checks

| Command | Result |
|---|---|
| `flutter analyze` | PASS; no issues found |
| `dart analyze` | PASS; no issues found |
| `flutter test` | PASS; 1 test passed |
| `flutter pub get` | PASS; dependencies resolved |
| `git diff --check` | PASS |

The existing test only verifies that delete, security-setting, and payment tool IDs are classified as blocked.

### Baseline failures

| Command | Result | Existing cause |
|---|---|---|
| `dart format --set-exit-if-changed lib test` | FAIL | Existing Dart files are not formatted according to the current formatter |
| `flutter build apk --debug` | FAIL before app compilation | Flutter reports use of the deleted Android v1 embedding |

The formatting command was run as a check and its incidental formatting changes were discarded. No application behavior was changed by this baseline milestone.

## Build-system observations

The tracked Android inventory contains the manifest, Kotlin activity, generated plugin registration, and accessibility XML, but no Gradle wrapper or build configuration files. This is separate from the v1 embedding error and must be resolved before a repeatable Android debug or release build can exist.

## Source-size observations

- 13 Dart files are tracked under `lib/`.
- `lib/main.dart` is the dominant source file at roughly 3.6k lines in the working tree.
- The file contains UI, models, state, mock providers, command routing, and service-like abstractions together.

## Baseline conclusion

The Dart layer is analyzable and the narrow unit test passes, but the Android artifact is not buildable and the format gate is not clean. These are baseline conditions, not regressions from the Phase 0-1 documentation changes.

## Milestone 1 update

The Android host was regenerated with the current Flutter embedding and tracked Gradle configuration. After restoring the application sources and fixing the accessibility description resource reference:

| Command | Result |
|---|---|
| `flutter analyze` | PASS; no issues found |
| `flutter test` | PASS; 3 tests passed |
| `flutter build apk --debug` | PASS; `build/app/outputs/flutter-apk/app-debug.apk` |
