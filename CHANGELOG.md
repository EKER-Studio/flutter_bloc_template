# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-09-09

### Release v1.2.0 — Architecture Audits, Governance & Release Automation

Consolidated release hardening the BLoC production blueprint with automated GitHub Actions release pipelines, expanded unit test coverage, domain purity restoration, developer audit tooling, and repository governance.

Compare: [`v1.1.0...v1.2.0`](https://github.com/EKER-Studio/flutter_bloc_template/compare/v1.1.0...v1.2.0)

#### 🚀 Highlights & Features

* **CI/CD & Automated Release Pipeline:**
  * Adopted `develop` as the primary integration branch and default branch on GitHub, strictly separating development from production releases.
  * Added dedicated Release workflow ([`release.yml`](.github/workflows/release.yml)) to automatically build release APKs, upload artifacts, and publish GitHub Releases on `v*` tags.
  * Enhanced CI test stability on Linux runners with dynamic caching and fetching of the native `libisar.so` core binary.
  * Integrated automated test coverage calculation, summary tables in `$GITHUB_STEP_SUMMARY`, and `coverage/lcov.info` artifact reporting.
  * Pinned Flutter version to `3.47.2` for Dart analyzer and dependency compatibility.
  * Added conditional release keystore signing via `key.properties` in Android Gradle with automatic fallback to debug keys.
* **Architecture & Clean Code Refinement:**
  * Restored domain purity by extracting UI localized message logic out of `Failure` entity into `FailureUserMessage` extension in presentation.
  * Registered `AppThemeBloc` as an `@injectable` factory instead of singleton for lifecycle safety.
  * Localized application title dynamically via `onGenerateTitle` in `MaterialApp.router`.
  * Fixed `SingleChildScrollView` layout wrapping in `TodoScreenDetail` to prevent keyboard and small-screen overflow.
  * Reset stream retry counters on successful emissions in Isar repositories (`TodoRepositoryImpl`, `UserPreferencesRepositoryImpl`).
  * Moved `flutter_native_splash` to `dev_dependencies` to optimize production dependencies.
  * Comprehensive comment and DartDoc cleanup across `app`, `core`, `settings`, and `todos` modules.
* **Test Suite & Quality Assurance:**
  * Added extensive unit tests covering the `Failure` sealed hierarchy and `FailureUserMessage` extension.
  * Added unit tests for `UserPreferences` entity, use cases (`WatchUserPreferencesUseCase`, `UpdateThemeModeUseCase`, `UpdateNotificationsEnabledUseCase`), repository (`UserPreferencesRepositoryImpl`), and mapper (`UserPreferencesMapper`).
  * Added unit tests for `Todo` entity, use cases (`WatchTodosUseCase`, `AddTodoUseCase`, `ToggleTodoUseCase`, `DeleteTodoUseCase`, `RestoreTodoUseCase`), repository (`TodoRepositoryImpl`), and date formatting helper (`formatTodoDate`).
  * Fixed resource leaks in fake repositories (`FakeTodoRepository`, `FakeUserPreferencesRepository`) and BLoC test suites.
* **Developer Tooling & Architecture Audits:**
  * Added specialized AI audit prompts in `prompts/` covering deep BLoC architecture audit, unit testing framework, i18n/l10n audits, and DartDoc cleanup.
  * Added GitHub Copilot project guidelines ([`.github/copilot-instructions.md`](.github/copilot-instructions.md)).
  * Added canonical 5-step feature scaffold guide to `README.md`.
* **Repository Governance & Project Hygiene:**
  * Added standardized GitHub Issue templates (bug, feature, config) and PR templates (feature, bug_fix, chore).
  * Formalized contribution and branch workflows in [`.github/CONTRIBUTING.md`](.github/CONTRIBUTING.md).
  * Hardened `.gitignore` to track Firebase options while ignoring local keystores, build artifacts, and agent audit directories.

## [1.1.0] - 2026-08-28

### Release v1.1.0 — Production Blueprint & Tooling Upgrade

Major architectural enhancement upgrading the BLoC boilerplate from a minimal starter into a full-featured, AI-native enterprise production blueprint. This release consolidates routing, domain layer, theming, localization, and tooling to production-grade standards.

Compare: [`v1.0.0...v1.1.0`](https://github.com/EKER-Studio/flutter_bloc_template/compare/v1.0.0...v1.1.0)

#### 🚀 Highlights & Features

* **Declarative Routing (GoRouter):** Integrated `go_router` with centralized route definitions in `lib/core/router/app_router.dart`, eliminating direct cross-screen dependencies and enabling deep-link ready navigation (`/todo/:id`).
* **Architecture Evolution — Domain Use Cases & Hydrated State:**
  * Introduced explicit Domain Use Cases layer (`watch_todos`, `add_todo`, `toggle_todo`, `delete_todo`, `restore_todo`, `watch_user_preferences`, `update_theme_mode`, `update_notifications_enabled`) and refactored `TodoBloc`/`SettingsBloc` to depend on use cases instead of repositories directly.
  * Upgraded `AppThemeBloc` from `Cubit` to `HydratedBloc` for automatic persistence of theme preference across restarts.
* **Environment & Flavor Isolation:** Added `AppConfig` / `AppEnvironment` runtime switching via `--dart-define=APP_ENV` and automated `.dev` application ID suffixes for Android (`build.gradle.kts`) and iOS (`project.pbxproj`) debug/profile builds, plus `(Dev)` display name suffix.
* **Design System & Asset Pipeline:** Centralized `AppTheme` (Material 3 `ColorScheme` + `TextTheme`) as single source of truth, added reusable core widgets (`AppEmptyView`, `AppErrorView`, `AppLoadingIndicator`), adaptive/launcher icons (including iOS 18 dark/tinted + Android 13 monochrome/themed), dynamic light/dark native splash screens (`flutter_native_splash`), and asset normalization scripts (`scripts/build_app_icons.sh`, `scripts/normalize_material_icon.sh` + SVG sources).
* **Hardened CI/CD & Build Integrity:** Updated GitHub Actions (`ci.yml`) with pub cache, `flutter gen-l10n` step, `dart format`/`flutter analyze` gates, `flutter test --exclude-tags golden`, and native Android Debug APK build verification with automatic artifact uploads. Added `scripts/before_push.sh` as canonical local verification pipeline.
* **AI-Native Tooling:** Added universal guardrail configs for Cline (`.clinerules`), Cursor (`.cursor/rules/agents.mdc`, `.cursorignore`, `.cursorindexingignore`), and documentation hubs (`CLAUDE.md`, `GEMINI.md` referencing `AGENTS.md`/`agents_project.md`) for consistent AI-assisted development.

#### Added

* `lib/core/router/app_router.dart` — centralized `GoRouter` with `TodoScreen` and `TodoScreenDetail` routes.
* `lib/core/config/app_environment.dart` + `AppConfig` — environment-aware config (`development`/`production`, `APP_ENV` dart-define).
* `lib/core/presentation/theme/app_theme.dart` — Material 3 light/dark themes and typography.
* `lib/core/presentation/widgets/` — `app_empty_view.dart`, `app_error_view.dart`, `app_loading_indicator.dart`.
* `lib/core/presentation/bloc/app_theme_bloc.dart`, `app_theme_event.dart` (migrated from `cubit/`), `lib/features/settings/presentation/bloc/settings_bloc.dart`, `settings_event.dart` (migrated from `cubit/`).
* `lib/features/todos/domain/use_cases/` (5) and `lib/features/settings/domain/use_cases/` (3) — pure domain use cases.
* `lib/core/errors/failure.dart` — expanded sealed `Failure` hierarchy (`DatabaseFailure`, `NotFoundFailure`, `NetworkFailure`, `UnauthorizedFailure`, `ValidationFailure`) with `localizedMessage` on `BuildContext`.
* `lib/l10n/` — enriched `app_en.arb`/`app_pl.arb` (error states, a11y labels, settings), regenerated `app_localizations*.dart` (EN/PL).
* `agents_project.md` — project-specific BLoC state-management and guardrail rules; extended `AGENTS.md`.
* `.clinerules`, `.cursor/rules/agents.mdc`, `.cursorignore`, `.cursorindexingignore`, `CLAUDE.md`, `GEMINI.md` — AI tooling configs.
* `scripts/build_app_icons.sh`, `scripts/normalize_material_icon.sh` — icon pipeline; `scripts/before_push.sh` (moved from root `before_push.sh`).
* `test/helpers/mock_hydrated_storage.dart` — `MockStorage` helper for `HydratedBloc` tests.
* Assets: `assets/icon/app_icon*`, `splash_light/dark.*` (PNG+SVG), Android `mipmap-*`/`drawable-*` (including `-night` + adaptive), iOS `AppIcon` + `LaunchImage`/`LaunchBackground` sets.

#### Changed

* `lib/app.dart`, `lib/main.dart` — wired `MaterialApp.router`, `MultiBlocProvider` with `AppThemeBloc`/`SettingsBloc`, hydrated storage init.
* `lib/features/*/presentation/screens/` — `todo_screen.dart`, `todo_screen_detail.dart`, `settings_screen.dart` now use `GoRouter` navigation, localized strings (`context.l10n`), and `Failure.localizedMessage`.
* `lib/features/todos/presentation/widgets/` — `todo_list_item.dart` uses `context.go`, `add_todo_fab.dart` localized.
* `lib/features/settings/data/repositories/user_preferences_repository_impl.dart` — optimized Isar transaction (single `writeTxn` for singleton upsert).
* `README.md` — full rewrite (reference architecture, mermaid class/sequence diagrams, feature-first structure, verification section).
* `AGENTS.md`, `analysis_options.yaml` — tightened lints (`custom_lint` via `before_push.sh`, `flutter analyze` canonical), removed obsolete `import_lint`/`code size tracking`.
* `.github/workflows/ci.yml` — modernized (setup-java v5, Flutter 3.47.0, caching, gen-l10n, build_runner, Android APK verification).
* `.gitignore` — expanded (`.env`, Isar, generated, VS Code, coverage).
* `pubspec.yaml` — `flutter 3.47.0`, added `go_router`, `hydrated_bloc`, `flutter_native_splash`, `flutter_launcher_icons`; removed `dio`, `import_lint` remnants.

#### Fixed

* Prevent false deletion trigger in `TodoDetailScreen` when marking complete (`todo_detail_screen.dart`).
* Use declarative navigation in `TodoListItem` (replace imperative `Navigator.push` with `GoRouter`).
* Optimize `UserPreferences` DB write to avoid redundant transactions.
* Correct i18n coverage: localized hardcoded UI strings and accessibility labels (`todo_screen`, `settings_screen`, `add_todo_fab`, `todo_list_item`); remove dead `save` key and add multi-locale widget tests.
* Test stability: fix `pumpAndSettle` pitfalls with `async*` injected streams, add `todo_screen_test.dart` coverage, update golden baselines.

#### Removed

* `lib/core/network/network_module.dart` + `dio` dependency — network layer intentionally deferred for local-first focus.
* `lib/core/presentation/cubit/` (`app_theme_cubit.dart`, `settings_cubit.dart`) — replaced by `bloc/` with events.
* Root `before_push.sh` — relocated to `scripts/before_push.sh`.
* Obsolete `analysis_options` rules and `.cursor` legacy configs.

#### Tooling & Documentation

* Standardized scripts to English, added `--delete-conflicting-outputs` handling and `build_runner` conflict flag.
* Cleaned up redundant comments in test mappers/widgets (`user_preferences_mapper_test.dart`, `todo_mapper_test.dart`, `add_todo_fab_test.dart`, `todo_list_item_test.dart`).

---

## [1.0.0] - 2026-07-29

### Release v1.0.0 — Certified AI-Native BLoC Template with Verified Guardrails

Initial stable release. Certified local-first blueprint with BLoC + GetIt + Injectable + Isar, comprehensive guardrails, and verified CI.

* Feature-first Clean Architecture (Domain/Data/Presentation)
* `Todo` CRUD + reactive Isar watch streams + synchronous mappers
* `Settings` singleton (`id=0`) with theme persistence
* `flutter_lints` + `custom_lint` verification, `flutter test` + golden tests
* `gen-l10n` EN/PL support, `build_runner` codegen
* GitHub Actions CI and `before_push.sh` pipeline

## [0.9.0] - 2026-02-15

### Release v0.9.0 — Full feature-rich BLoC boilerplate baseline

Pre-stable baseline for internal validation. Full `Todo` + `Settings` features, Isar integration, and initial documentation.

[1.2.0]: https://github.com/EKER-Studio/flutter_bloc_template/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/EKER-Studio/flutter_bloc_template/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/EKER-Studio/flutter_bloc_template/compare/v0.9.0-full-bloc-baseline...v1.0.0
[0.9.0]: https://github.com/EKER-Studio/flutter_bloc_template/releases/tag/v0.9.0-full-bloc-baseline
