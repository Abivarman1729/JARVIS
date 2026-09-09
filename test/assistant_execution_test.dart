import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/models/assistant_execution.dart';

void main() {
  test('tool results expose verified success only for succeeded operations',
      () {
    const success = ToolResult(
      callId: 'call-1',
      status: OperationStatus.succeeded,
      output: 'verified',
    );
    const failure = ToolResult(
      callId: 'call-2',
      status: OperationStatus.failed,
    );

    expect(success.isSuccess, isTrue);
    expect(failure.isSuccess, isFalse);
  });

  test('errors retain a typed category', () {
    const error = JarvisError(
      category: JarvisErrorCategory.authenticationRequired,
      message: 'Authentication is required.',
    );

    expect(error.category, JarvisErrorCategory.authenticationRequired);
    expect(error.toString(), contains('authenticationRequired'));
  });
}
