class JarvisMessage {
  const JarvisMessage({required this.role, required this.text, required this.timestamp});
  final String role;
  final String text;
  final DateTime timestamp;
}

enum RiskLevel { safe, confirm, sensitive, blocked }

enum PermissionState { denied, ask, granted }

class ToolPermission {
  const ToolPermission({required this.id, required this.label, required this.state});
  final String id;
  final String label;
  final PermissionState state;
}

class JarvisAction {
  const JarvisAction({required this.tool, required this.arguments, required this.risk});
  final String tool;
  final Map<String, dynamic> arguments;
  final RiskLevel risk;
}

class MemoryItem {
  const MemoryItem({required this.id, required this.text, required this.createdAt, required this.userApproved, this.sensitive = false});
  final String id;
  final String text;
  final DateTime createdAt;
  final bool userApproved;
  final bool sensitive;
}

class DeviceInfo {
  const DeviceInfo({required this.id, required this.name, required this.platform, required this.paired});
  final String id;
  final String name;
  final String platform;
  final bool paired;
}
