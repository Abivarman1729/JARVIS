import 'dart:convert';
import 'package:crypto/crypto.dart';

abstract interface class AuthenticationService {
  Future<bool> authenticate();
}

class SecurityManager {
  SecurityManager({
    required this.authentication,
    this.sessionMinutes = 15,
  });

  final AuthenticationService authentication;
  final int sessionMinutes;
  DateTime? _authenticatedAt;

  Future<bool> authorizeSession() async {
    final now = DateTime.now();
    if (_authenticatedAt != null &&
        now.difference(_authenticatedAt!).inMinutes < sessionMinutes) {
      return true;
    }
    final authenticated = await authentication.authenticate();
    if (!authenticated) {
      _authenticatedAt = null;
      return false;
    }
    _authenticatedAt = now;
    return true;
  }

  void logout() => _authenticatedAt = null;

  String hashForAudit(String value) =>
      sha256.convert(utf8.encode(value)).toString();
}
