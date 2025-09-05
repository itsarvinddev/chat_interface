# ChatUI Flutter Package

ChatUI is a comprehensive Flutter package providing advanced chat UI components including threading, polls, contact sharing, reactions, and smooth animations. It includes serializable models using dart_mappable code generation and a complete example application demonstrating Supabase integration.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites and Installation
- **CRITICAL**: Requires Dart SDK ^3.9.0 and Flutter >=1.17.0
- Install Flutter SDK (includes required Dart SDK):
  - Download: `wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz`
  - Extract: `tar xf flutter_linux_3.24.5-stable.tar.xz`
  - Add to PATH: `export PATH="$PATH:/path/to/flutter/bin"`
  - Verify installation: `flutter doctor` -- takes 30-60 seconds, checks dependencies
  - **NOTE**: Available Flutter 3.24.5 includes Dart 3.5.x which may be insufficient - you may need Flutter dev channel or newer release for Dart ^3.9.0

### Core Development Workflow
- Bootstrap the package:
  - `flutter pub get` -- installs dependencies, takes 2-3 minutes. NEVER CANCEL. Set timeout to 5+ minutes.
  - `dart run build_runner build` -- generates code for dart_mappable models, takes 1-2 minutes. NEVER CANCEL. Set timeout to 3+ minutes.
- Linting and code quality:
  - `flutter analyze` -- analyzes Dart code for issues, takes 30-60 seconds
  - `dart format .` -- formats all Dart code, takes ~1 second (measured: 0.9s for 38 files)
  - `dart format --set-exit-if-changed --output=none .` -- check formatting without changes, exits with code 1 if formatting needed
- Testing:
  - Package tests: `flutter test` -- runs package unit tests, takes 1-2 minutes. NEVER CANCEL. Set timeout to 5+ minutes.
  - Example app tests: `cd example && flutter test` -- runs example app tests

### Running the Example Application
- ALWAYS run bootstrap steps first (pub get + code generation)
- Navigate to example directory: `cd example`
- Install example dependencies: `flutter pub get` -- takes 2-3 minutes. NEVER CANCEL. Set timeout to 5+ minutes.
- Run on available platforms:
  - Web: `flutter run -d web-server --web-port 8080` -- starts dev server, takes 3-5 minutes initial build. NEVER CANCEL. Set timeout to 10+ minutes.
  - Linux: `flutter run -d linux` -- builds and runs native Linux app, takes 5-10 minutes. NEVER CANCEL. Set timeout to 15+ minutes.
  - Android emulator: `flutter run -d android` -- builds and runs on Android emulator if available

### Code Generation Workflow
- This package uses dart_mappable for model serialization
- Generated files are in version control (.mapper.dart files)
- When modifying models in `lib/src/models/`, regenerate code:
  - `dart run build_runner build --delete-conflicting-outputs` -- force rebuild all generated files, takes 1-2 minutes
  - `dart run build_runner watch` -- continuously regenerates on file changes (for development)

## Validation

### Manual Testing Scenarios
- ALWAYS run through at least one complete end-to-end scenario after making changes:
  1. **Basic Chat Flow**: Start example app, verify chat interface loads, send a text message, verify message appears
  2. **Attachment Flow**: Send an image attachment, verify it displays correctly
  3. **Theme Switching**: Toggle between light/dark themes using floating action button
  4. **Emoji/Reactions**: Test emoji picker and message reactions functionality
- When testing web version, open browser to `http://localhost:8080` and interact with the chat interface
- Take screenshots of any UI changes for verification

### Build Validation
- Always run these commands before committing changes:
  - `flutter analyze` -- must pass with zero issues
  - `dart format --set-exit-if-changed --output=none .` -- must exit with code 0 (no formatting needed)
  - `flutter test` -- all tests must pass
  - `cd example && flutter test` -- example tests must pass
- CI will fail if any of these commands fail

## Repository Structure

### Key Directories
- `lib/src/`: Main package source code (33 Dart files total)
  - `models/`: Data models with dart_mappable serialization (message.dart, chat_user.dart, enums.dart + 3 .mapper.dart files)
  - `widgets/`: UI components and chat widgets (10 Dart files)
  - `theme/`: Theme system and customization
  - `core/`: Controllers and providers
  - `utils/`: Utility functions and helpers
- `example/`: Complete demo application showing package usage
  - `lib/main.dart`: Main app with Supabase integration demonstrating real chat functionality
  - `lib/chat_pagination_service.dart`: Pagination logic for chat messages
  - `lib/supabase_extensions.dart`: Database helper extensions
- `assets/images/`: Package assets (6 PNG files for message status: PENDING.png, SENT.png, DELIVERED.png, SEEN.png, image.png, avatar.png)

### Important Files
- `pubspec.yaml`: Package definition, requires Flutter >=1.17.0 and Dart ^3.9.0
- `lib/chatui.dart`: Main package export file and initialization
- `lib/src/models/*.mapper.dart`: Generated serialization code (in version control)
- `API_DOCUMENTATION.md`: Comprehensive API documentation with examples
- `THEME_CUSTOMIZATION.md`: Theme system documentation

### Generated Code
- **Generated files ARE committed to version control** (unlike typical Dart projects)
- Files ending in `.mapper.dart` are auto-generated by dart_mappable:
  - `lib/src/models/chat_user.mapper.dart` (9.6KB)
  - `lib/src/models/enums.mapper.dart` (10.4KB) 
  - `lib/src/models/message.mapper.dart` (31.4KB)
- NEVER edit .mapper.dart files manually - they will be overwritten
- When changing @MappableClass annotated models (5 classes total), always regenerate code before committing
- If mapper files are missing or corrupt: `dart run build_runner build --delete-conflicting-outputs`

## Common Issues and Solutions

### Dependencies and SDK
- **SDK Compatibility Issue**: Package requires Dart ^3.9.0 but latest stable Flutter (3.24.5) includes Dart 3.5.x
- If `flutter pub get` fails with "version solving failed" due to SDK version:
  - Check your Dart version: `dart --version`
  - Try Flutter dev/beta channel: `flutter channel dev && flutter upgrade`
  - Or wait for newer stable Flutter release with Dart 3.9+
- Missing build_runner errors: Run `dart run build_runner build` after pub get
- Flutter command not found: Ensure Flutter SDK is in PATH and `flutter doctor` passes
- **NOTE**: `dart analyze` without dependencies shows 2074+ issues (expected) - only run after `flutter pub get`

### Code Generation
- If mapper errors occur: Delete `.dart_tool/build/` and run `dart run build_runner build --delete-conflicting-outputs`
- If build_runner hangs: Stop with Ctrl+C, delete `.dart_tool/build/`, and retry
- Missing mapper imports: Ensure models have `part 'filename.mapper.dart';` declarations

### Example App Issues
- **CRITICAL**: Example app requires `initializeChatUI()` call in main() - see `example/lib/main.dart:18`
- Supabase connection errors are expected - example uses demo credentials for https://hyycwsqoszrjcznvgyzp.supabase.co
- If example won't start: Ensure you ran `flutter pub get` in both root and example directories
- Web CORS issues: Use `flutter run -d web-server` instead of `flutter run -d chrome`
- If getting "ChatUI not initialized" errors: Ensure `initializeChatUI()` is called before `runApp()`

## Development Best Practices

### Making Changes
- Always run full test suite after changes: `flutter test && cd example && flutter test`
- When adding new models, follow existing patterns in `lib/src/models/`
- Use existing theme system defined in `lib/src/theme/` for UI consistency
- Check both package and example app functionality after model changes

### Code Style
- Follow standard Dart formatting: `dart format .` (takes ~1 second)
- Linting configuration: Uses `flutter_lints: ^5.0.0` with standard Flutter package rules
- Use descriptive variable names and add documentation for public APIs
- Follow patterns established in existing code for consistency
- Add tests for new functionality in appropriate test files
- **NOTE**: Code in this repository currently needs formatting - always run `dart format .` before committing

### Performance Considerations
- Large asset files should be optimized before adding to `assets/`
- When modifying list rendering, test with large message datasets
- Chat scroll performance is critical - test scrolling through hundreds of messages

## Package Publishing Notes
- Version defined in pubspec.yaml (currently 0.0.2)
- Homepage: https://github.com/yourusername/your-repo (update in pubspec.yaml)
- This is a pure Flutter package, not a plugin
- Supports all Flutter platforms (iOS, Android, Web, Desktop)

## Common Command Outputs

### Repository Root Structure
```
ls -la
total 76
drwxr-xr-x  6 runner docker  4096 .
drwxr-xr-x  3 runner docker  4096 ..
drwxr-xr-x  7 runner docker  4096 .git
drwxr-xr-x  2 runner docker  4096 .github
-rw-r--r--  1 runner docker   573 .gitignore
-rw-r--r--  1 runner docker   313 .metadata
-rw-r--r--  1 runner docker 13479 API_DOCUMENTATION.md
-rw-r--r--  1 runner docker    44 CHANGELOG.md
-rw-r--r--  1 runner docker    29 LICENSE
-rw-r--r--  1 runner docker  1258 README.md
-rw-r--r--  1 runner docker  3797 THEME_CUSTOMIZATION.md
-rw-r--r--  1 runner docker   154 analysis_options.yaml
drwxr-xr-x  3 runner docker  4096 assets
-rw-r--r--  1 runner docker   184 devtools_options.yaml
drwxr-xr-x 10 runner docker  4096 example
drwxr-xr-x  3 runner docker  4096 lib
-rw-r--r--  1 runner docker  1458 pubspec.yaml
```

### Expected dart format output
```
dart format .
Formatted 38 files (20 changed) in 0.90 seconds.
```

## Current SDK Limitation Notes
- **Current Status**: This repository requires Dart ^3.9.0 but stable Flutter only provides Dart 3.5.x
- **What works with current SDK**: `dart format`, `dart analyze` (with errors), file structure analysis
- **What requires proper SDK**: `flutter pub get`, `dart run build_runner build`, `flutter test`, `flutter run`
- **Resolution**: Use Flutter dev channel or wait for stable release with Dart 3.9.0+ support

## Timeout Guidelines
- **CRITICAL**: NEVER CANCEL build or test commands. Builds may take 10+ minutes on first run.
- `flutter pub get`: 5+ minute timeout
- `dart run build_runner build`: 3+ minute timeout  
- `flutter test`: 5+ minute timeout
- `flutter run`: 15+ minute timeout for initial builds
- When in doubt, wait longer rather than canceling commands