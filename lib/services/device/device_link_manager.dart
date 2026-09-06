import '../../models/jarvis_models.dart';

abstract interface class DeviceTransport {
  Future<void> send(DeviceInfo target, Map<String, dynamic> message);
  Future<List<DeviceInfo>> pairedDevices();
  Future<void> revoke(DeviceInfo device);
}

class DeviceLinkManager {
  DeviceLinkManager(this.transport);
  final DeviceTransport transport;

  Future<void> sendTo(String deviceId, Map<String, dynamic> message) async {
    final devices = await transport.pairedDevices();
    final target = devices.firstWhere((d) => d.id == deviceId, orElse: () => throw StateError('Unknown paired device'));
    if (!target.paired) throw StateError('Device is not paired');
    await transport.send(target, message);
  }
}
