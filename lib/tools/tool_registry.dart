import '../models/jarvis_models.dart';

class ToolDefinition {
  const ToolDefinition(
      {required this.id, required this.description, required this.risk});
  final String id;
  final String description;
  final RiskLevel risk;
}

class ToolRegistry {
  static final List<ToolDefinition> defaults = [
    ToolDefinition(
        id: 'open_app',
        description: 'Open an installed application',
        risk: RiskLevel.safe),
    ToolDefinition(
        id: 'web_search',
        description: 'Search the public web',
        risk: RiskLevel.safe),
    ToolDefinition(
        id: 'send_message',
        description: 'Send a message on behalf of the user',
        risk: RiskLevel.confirm),
    ToolDefinition(
        id: 'transfer_file',
        description: 'Transfer selected files to a paired device',
        risk: RiskLevel.confirm),
    ToolDefinition(
        id: 'change_security_settings',
        description: 'Change security settings',
        risk: RiskLevel.blocked),
    ToolDefinition(
        id: 'delete_file',
        description: 'Delete a file',
        risk: RiskLevel.blocked),
    ToolDefinition(
        id: 'execute_payment',
        description: 'Execute a payment',
        risk: RiskLevel.blocked),
  ];

  ToolDefinition? definitionFor(String id) {
    for (final definition in defaults) {
      if (definition.id == id) return definition;
    }
    return null;
  }

  RiskLevel riskFor(String id) => defaults
      .firstWhere((t) => t.id == id,
          orElse: () => const ToolDefinition(
              id: 'unknown', description: '', risk: RiskLevel.blocked))
      .risk;

  JarvisAction? inferAction(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('delete file'))
      return const JarvisAction(
          tool: 'delete_file', arguments: {}, risk: RiskLevel.blocked);
    if (lower.contains('payment') || lower.contains('pay '))
      return const JarvisAction(
          tool: 'execute_payment', arguments: {}, risk: RiskLevel.blocked);
    if (lower.contains('send'))
      return const JarvisAction(
          tool: 'send_message', arguments: {}, risk: RiskLevel.confirm);
    if (lower.contains('search'))
      return const JarvisAction(
          tool: 'web_search', arguments: {}, risk: RiskLevel.safe);
    return null;
  }
}
