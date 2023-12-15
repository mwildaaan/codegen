class Env {
  Env(this.config);

  final EnvConfig config;
}

mixin EnvValue {
  static final Env development = Env(EnvConfig(
    baseUrl: "https://haibarr-dev.id",
    stage: '(dev)',
    label: "dev",
  ));
  static final Env staging = Env(EnvConfig(
    baseUrl: "https://haibarr-staging.id",
    stage: '(staging)',
    label: "staging",
  ));
  static final Env production = Env(EnvConfig(
      baseUrl: "https://haibarr-prod.id",
      stage: '',
      label: "production"));
}

//
class EnvConfig {
  final String baseUrl;
  final String stage;
  final String label;

  EnvConfig({
    required this.baseUrl,
    required this.stage,
    required this.label,
  });
}
