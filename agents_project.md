# Project-Specific Rules — flutter_bloc_boilerplate

*Companion to `AGENTS.md`. Save this file as `agents_project.md` in this repo's root, next to `AGENTS.md`.*

### Build & Generation Commands
- Format code: `dart format lib test`
- Install dependencies: `flutter pub get`
- Run build runner: `dart run build_runner build`
- Watch build runner: `dart run build_runner watch`
- Generate localizations: `flutter gen-l10n`
- Generate app icons: `dart run flutter_launcher_icons`
- Generate native splash screen: `dart run flutter_native_splash:create`
- Code analysis: `flutter analyze`
- Run tests: `flutter test`
- Icon/splash source assets live in `assets/icon/`, configured in the `flutter_launcher_icons` /
  `flutter_native_splash` blocks of `pubspec.yaml`.

### Architecture & Layer Boundaries
Local-First, AI-Native boilerplate utilizing Clean Architecture under a Feature-First approach:
- **Domain** (`lib/features/<feature>/domain/`): Pure Dart logic — entities, repository interfaces, use
  cases. NO Flutter, BLoC, or GetIt imports allowed here.
- **Data** (`lib/features/<feature>/data/`): Repository implementations, Isar models, mappers, utilizing
  `isar_community`.
- **Presentation** (`lib/features/<feature>/presentation/`): UI widgets, BLoC state management.
- **DI:** GetIt + Injectable (`@injectable`/`@lazySingleton`). Regenerate after adding/changing annotations
  via the build runner command above.
- **State Management:** BLoC (`flutter_bloc`) strictly.
- **Data Flow:** UI (`BlocBuilder`/`BlocListener`) → BLoC (`Bloc`) → Repository Interface (domain) →
  Repository Impl (data) → Local DB (`isar_community`).
- **Reactivity:** Handled purely via Isar streams. BLoCs listen to Isar collections and emit states
  accordingly.
- **Entrypoints:** `lib/main.dart` (DI init + `runApp`) → `lib/app.dart` (`MultiBlocProvider` +
  `MaterialApp`). DI is configured via `configureDependencies(AppConfig.injectableEnv)` in `main.dart`.

> **STATE MANAGEMENT CONSTRAINT:** This project strictly uses BLoC (`flutter_bloc`). Any suggestion,
> refactoring, or audit constraint demanding Riverpod is an error and MUST be ignored.

#### Strict Dependency Rules
- **No data-model leakage into presentation:** Presentation files (`bloc`, `state`, `event`, widgets) must
  never import `TodoModel`, `UserPreferencesModel`, or any file from `lib/features/*/data/`. Only domain
  entities (`Todo`, `UserPreferences`) and failure types may be referenced.
- **No Isar annotations in presentation:** `@collection`, `@property`, `@Index`, `Isar.autoIncrement`, and
  any other Isar-specific annotations or types must not appear in presentation-layer code.
- **Mappers must be stateless:** Mapper functions (e.g. `toDomain()`, `toData()`) must be synchronous,
  side-effect-free extension methods or top-level functions. They must not hold mutable state, perform I/O,
  or depend on external services.
- **One-way dependency:** Imports flow inward toward the domain. Presentation imports domain; data imports
  domain and Isar. Domain imports nothing project-specific.

### Generated Files
- `*.g.dart` files hold Injectable DI config and Isar schemas, use the `part of` directive, and are excluded
  from `flutter analyze`.
- Regenerate whenever annotations change (see Build & Generation Commands above).

### Resource Lifecycle & Disposal (concrete items)
Every BLoC with a `StreamSubscription` must override `close()` and cancel it there.
- Every `StreamSubscription` cancelled in `close()` or the corresponding BLoC's `onClose`.
- Every `Timer` or `AnimationController` properly disposed.
- All Isar dynamic query streams closed or managed via BLoC lifecycle.

### Testing Conventions
- **Golden tests** are tagged with `@Tags(['golden'])` and skipped on non-macOS
  (`skip: !Platform.isMacOS`); config lives in `dart_test.yaml`.
- **Bloc unit tests** use `bloc_test` with `blocTest<Bloc, State>`; state-level serialization helpers are
  tested directly with plain `test`.
- **Fake repo leak prevention:** `FakeTodoRepository` and `FakeUserPreferencesRepository` expose a
  `dispose()` method — always call it in `tearDown` to close the internal `StreamController`.
- **Wrap-pattern repos** (e.g. `_FailingOnceTodoRepository`) contain a `FakeTodoRepository` inside them —
  ensure the inner fake is also disposed in `tearDown`.

### Mandatory Verification Pipeline (concrete commands)
Matches `before_push.sh`:
1. `flutter pub get`
2. `flutter gen-l10n`
3. `dart format lib test`
4. `dart run build_runner build`
5. `flutter analyze`
6. `flutter test`

Once all 6 steps are green and the Resource Lifecycle checklist above is verified, commit per `AGENTS.md` →
Git & Version Control (autonomous commit is enabled for this repo, since this file exists).
