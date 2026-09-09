enum AssistantState {
  idle,
  listening,
  understanding,
  planning,
  awaitingConfirmation,
  executing,
  verifying,
  completed,
  failed,
  cancelled,
}

enum OperationStatus {
  pending,
  succeeded,
  failed,
  denied,
  unsupported,
  cancelled,
}

enum JarvisErrorCategory {
  authenticationRequired,
  permissionDenied,
  confirmationRequired,
  invalidInput,
  timeout,
  cancelled,
  securityBlocked,
  unsupported,
  networkFailure,
  storageFailure,
  platformFailure,
  toolFailure,
  aiFailure,
  unexpected,
}

class JarvisError implements Exception {
  const JarvisError({
    required this.category,
    required this.message,
    this.cause,
  });

  final JarvisErrorCategory category;
  final String message;
  final Object? cause;

  @override
  String toString() => 'JarvisError(${category.name}): $message';
}

class ToolCall {
  const ToolCall({
    required this.id,
    required this.toolId,
    required this.arguments,
  });

  final String id;
  final String toolId;
  final Map<String, Object?> arguments;
}

class ToolResult {
  const ToolResult({
    required this.callId,
    required this.status,
    this.output,
    this.error,
  });

  final String callId;
  final OperationStatus status;
  final Object? output;
  final JarvisError? error;

  bool get isSuccess => status == OperationStatus.succeeded;
}

class ExecutionRecord {
  const ExecutionRecord({
    required this.id,
    required this.state,
    required this.startedAt,
    this.completedAt,
    this.toolResults = const [],
  });

  final String id;
  final AssistantState state;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<ToolResult> toolResults;
}
