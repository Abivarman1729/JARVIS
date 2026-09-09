import '../models/assistant_execution.dart';
import '../models/jarvis_models.dart';
import '../services/ai/ai_orchestrator.dart';
import '../services/memory/memory_manager.dart';
import '../services/security/security_manager.dart';
import '../services/voice/voice_manager.dart';
import '../tools/tool_execution.dart';
import '../tools/tool_registry.dart';

class JarvisController {
  JarvisController({
    required this.orchestrator,
    required this.memory,
    required this.security,
    required this.voice,
    required this.tools,
    this.executor,
  });

  final AiOrchestrator orchestrator;
  final MemoryManager memory;
  final SecurityManager security;
  final VoiceManager voice;
  final ToolRegistry tools;
  final ToolExecutor? executor;

  Future<String> handleUserText(String text) async {
    final session = await security.authorizeSession();
    if (!session)
      return 'I can listen, but I cannot execute commands until your JARVIS session is authenticated.';
    final action = tools.inferAction(text);
    if (action != null && executor != null) {
      final result = await executor!.execute(
        ToolCall(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          toolId: action.tool,
          arguments: Map<String, Object?>.from(action.arguments),
        ),
        authenticated: true,
        confirmed: false,
      );
      if (!result.isSuccess) {
        return result.error?.message ??
            'JARVIS could not complete that tool request.';
      }
      return 'JARVIS completed and verified ${action.tool}.';
    }
    return orchestrator.respond(text);
  }

  Future<String> handleVoiceInput(String text) async {
    final verified = await voice.verifyCurrentSpeaker();
    if (!verified)
      return 'I could not verify your voice, so I did not execute that request.';
    return handleUserText(text);
  }

  Future<bool> requestMemorySave(String text, {bool sensitive = false}) =>
      memory.saveApproved(text, sensitive: sensitive);

  RiskLevel riskFor(String tool) => tools.riskFor(tool);
}
