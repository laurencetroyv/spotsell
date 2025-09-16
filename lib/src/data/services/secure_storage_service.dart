import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/web.dart';

import 'package:spotsell/src/core/utils/result.dart';

class SecureStorageService {
  static const _tokenKey = 'session';

  final _log = Logger();

  static final storage = FlutterSecureStorage();

  Future<Result<String?>> fetchSession() async {
    try {
      _log.i('Get session from SecureStorage');
      return Result.ok(await storage.read(key: _tokenKey));
    } on Exception catch (error) {
      _log.w('Failed to get session', error: error);
      return Result.error(error);
    }
  }

  Future<Result<void>> saveSession(String? session) async {
    try {
      if (session == null) {
        _log.i('Removed session');
        await storage.delete(key: _tokenKey);
      } else {
        _log.i('Replaced session');
        await storage.write(key: _tokenKey, value: session);
      }
      return Result.ok(null);
    } on Exception catch (error) {
      _log.w('Failed to save session', error: error);
      return Result.error(error);
    }
  }
}
