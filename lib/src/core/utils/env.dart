// ignore_for_file: non_constant_identifier_names

import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API', obfuscate: true)
  static final String API = _Env.API;

  @EnviedField(varName: 'SENTRY_DNS', obfuscate: true)
  static final String SENTRY_DNS = _Env.SENTRY_DNS;

  @EnviedField(varName: 'ENVIRONMENT', obfuscate: true)
  static final String ENVIRONMENT = _Env.ENVIRONMENT;
}
