enum AppEnvironment { dev, staging, prod }

class AppConfig {
  const AppConfig._();

  static const _envName = String.fromEnvironment('ENV', defaultValue: 'dev');

  static final AppEnvironment environment = AppEnvironment.values.firstWhere(
    (e) => e.name == _envName,
    orElse: () => AppEnvironment.dev,
  );

  static bool get isProd => environment == AppEnvironment.prod;
}
