import '../models/assistant_execution.dart';
import '../models/jarvis_models.dart';
import 'tool_registry.dart';

typedef ToolHandler = Future<Object?> Function(Map<String, Object?> arguments);
typedef ToolVerifier = Future<bool> Function(
  Map<String, Object?> arguments,
  Object? output,
);

class ToolAuthorizer {
  const ToolAuthorizer();

  JarvisError? authorize(
    ToolDefinition definition, {
    required bool authenticated,
    required bool confirmed,
  }) {
    if (definition.risk == RiskLevel.blocked) {
      return const JarvisError(
        category: JarvisErrorCategory.securityBlocked,
        message: 'This tool is blocked by security policy.',
      );
    }
    if (!authenticated) {
      return const JarvisError(
        category: JarvisErrorCategory.authenticationRequired,
        message: 'Authentication is required for this tool.',
      );
    }
    if (definition.risk == RiskLevel.confirm && !confirmed) {
      return const JarvisError(
        category: JarvisErrorCategory.confirmationRequired,
        message: 'User confirmation is required for this tool.',
      );
    }
    return null;
  }
}

class ToolExecutor {
  ToolExecutor({
    required ToolRegistry registry,
    ToolAuthorizer authorizer = const ToolAuthorizer(),
    Map<String, ToolHandler> handlers = const {},
    Map<String, ToolVerifier> verifiers = const {},
  })  : _registry = registry,
        _authorizer = authorizer,
        _handlers = handlers,
        _verifiers = verifiers;

  final ToolRegistry _registry;
  final ToolAuthorizer _authorizer;
  final Map<String, ToolHandler> _handlers;
  final Map<String, ToolVerifier> _verifiers;

  Future<ToolResult> execute(
    ToolCall call, {
    required bool authenticated,
    required bool confirmed,
  }) async {
    final definition = _registry.definitionFor(call.toolId);
    if (definition == null) {
      return ToolResult(
        callId: call.id,
        status: OperationStatus.unsupported,
        error: const JarvisError(
          category: JarvisErrorCategory.unsupported,
          message: 'The requested tool is not registered.',
        ),
      );
    }

    final authorizationError = _authorizer.authorize(
      definition,
      authenticated: authenticated,
      confirmed: confirmed,
    );
    if (authorizationError != null) {
      final status = authorizationError.category ==
              JarvisErrorCategory.confirmationRequired
          ? OperationStatus.denied
          : OperationStatus.denied;
      return ToolResult(
        callId: call.id,
        status: status,
        error: authorizationError,
      );
    }

    final handler = _handlers[call.toolId];
    final verifier = _verifiers[call.toolId];
    if (handler == null || verifier == null) {
      return ToolResult(
        callId: call.id,
        status: OperationStatus.unsupported,
        error: const JarvisError(
          category: JarvisErrorCategory.unsupported,
          message:
              'The registered tool has no executable and verifiable handler.',
        ),
      );
    }

    final output = await handler(call.arguments);
    final verified = await verifier(call.arguments, output);
    if (!verified) {
      return ToolResult(
        callId: call.id,
        status: OperationStatus.failed,
        error: const JarvisError(
          category: JarvisErrorCategory.toolFailure,
          message: 'The tool executed but its result could not be verified.',
        ),
      );
    }
    return ToolResult(
      callId: call.id,
      status: OperationStatus.succeeded,
      output: output,
    );
  }
}
