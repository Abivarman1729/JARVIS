import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityManager {
  SecurityManager({this.sessionMinutes = 15});
  final int sessionMinutes;
  DateTime? _authenticatedAt;

  Future<bool> authorizeSession() async {
    final now = DateTime.now();
    if (_authenticatedAt != null && now.difference(_authenticatedAt!).inMinutes < sessionMinutes) return true;
    // Replace with Android BiometricPrompt / device credential bridge before production.
    _authenticatedAt = now;
    return true;
  }

  String hashForAudit(String value) => sha256.convert(utf8.encode(value)).toString();
}
