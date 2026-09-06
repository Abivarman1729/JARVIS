import '../../models/jarvis_models.dart';

abstract interface class PermissionGateway {
  Future<PermissionState> status(String permissionId);
  Future<bool> request(String permissionId);
  Future<bool> openSettings(String permissionId);
}

class PermissionManager {
  PermissionManager(this.gateway);
  final PermissionGateway gateway;

  Future<bool> ensure(String permissionId) async {
    final state = await gateway.status(permissionId);
    if (state == PermissionState.granted) return true;
    return gateway.request(permissionId);
  }

  Future<bool> openSettings(String permissionId) => gateway.openSettings(permissionId);
}
