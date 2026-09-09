import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/services/security/security_manager.dart';

class _AuthenticationStub implements AuthenticationService {
  _AuthenticationStub(this.result);

  final bool result;
  int calls = 0;

  @override
  Future<bool> authenticate() async {
    calls++;
    return result;
  }
}

void main() {
  test('does not authorize a rejected authentication', () async {
    final authenticator = _AuthenticationStub(false);
    final security = SecurityManager(authentication: authenticator);

    expect(await security.authorizeSession(), isFalse);
    expect(authenticator.calls, 1);
  });

  test('reuses a valid authenticated session and supports logout', () async {
    final authenticator = _AuthenticationStub(true);
    final security = SecurityManager(authentication: authenticator);

    expect(await security.authorizeSession(), isTrue);
    expect(await security.authorizeSession(), isTrue);
    expect(authenticator.calls, 1);

    security.logout();
    expect(await security.authorizeSession(), isTrue);
    expect(authenticator.calls, 2);
  });
}
