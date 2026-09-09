import 'package:flutter/services.dart';

import '../services/security/security_manager.dart';

class JarvisNativeBridge {
  const JarvisNativeBridge({
    this.channel = const MethodChannel('com.jarvis.app/native'),
  });

  final MethodChannel channel;

  Future<Map<String, Object?>> deviceInfo() async {
    final result = await channel.invokeMethod<Object?>('deviceInfo');
    return _mapResult(result);
  }

  Future<Map<String, Object?>> batteryInfo() async {
    final result = await channel.invokeMethod<Object?>('batteryInfo');
    return _mapResult(result);
  }

  Future<bool> openUrl(String url) async {
    final result = await channel.invokeMethod<Object?>(
      'openUrl',
      <String, Object?>{'url': url},
    );
    return result == true;
  }

  Future<bool> authenticate() async {
    final result = await channel.invokeMethod<Object?>('authenticate');
    return result == true;
  }

  Map<String, Object?> _mapResult(Object? result) {
    if (result is! Map) {
      throw PlatformException(
        code: 'invalid_result',
        message: 'The native bridge returned an invalid result.',
      );
    }
    return Map<String, Object?>.from(result);
  }
}

class NativeAuthenticationService implements AuthenticationService {
  const NativeAuthenticationService(this.bridge);

  final JarvisNativeBridge bridge;

  @override
  Future<bool> authenticate() => bridge.authenticate();
}
