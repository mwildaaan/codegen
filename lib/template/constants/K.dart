import 'env.dart';

class K {
  static String baseUrlUser = EnvValue.staging.config.label == "staging"
      ? 'https://reqres-user.in/api/'
      : 'https://haibarr-user-prod/api/';

  static String baseUrlCore = EnvValue.staging.config.label == "staging"
      ? 'https://reqres.in/api/'
      : 'https://haibarr-core-prod/api/';
}
