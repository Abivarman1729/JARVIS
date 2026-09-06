import '../../models/jarvis_models.dart';
import '../../tools/tool_registry.dart';

abstract interface class AiProvider {
  Future<String> generate(String input, {List<JarvisAction> actions});
}

class AiOrchestrator {
  AiOrchestrator({required this.provider, required this.tools});
  final AiProvider provider;
  final ToolRegistry tools;

  Future<String> respond(String input) async {
    final action = tools.inferAction(input);
    if (action != null && action.risk == RiskLevel.blocked) {
      return 'I cannot perform that action because it is blocked by JARVIS security policy.';
    }
    return provider.generate(input, actions: action == null ? const [] : [action]);
  }
}
