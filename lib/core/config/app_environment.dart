/// Supported application environments.
enum AppEnvironment {
  /// Development environment.
  dev,

  /// Production environment.
  prod,
}

/// Central application runtime configuration driven by compile-time `--dart-define`.
class AppConfig {
  const AppConfig._();

  static const _rawEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  /// The current [AppEnvironment] determined by the `APP_ENV` dart-define.
  static AppEnvironment get environment => AppEnvironment.values.firstWhere(
    (e) => e.name == _rawEnv,
    orElse: () => AppEnvironment.prod,
  );

  /// Whether the app is running in development mode.
  static bool get isDev => environment == AppEnvironment.dev;

  /// Whether the app is running in production mode.
  static bool get isProd => environment == AppEnvironment.prod;

  /// Returns the Injectable environment string corresponding to the active environment.
  static String get injectableEnv => switch (environment) {
    AppEnvironment.dev => 'dev',
    AppEnvironment.prod => 'prod',
  };
}
