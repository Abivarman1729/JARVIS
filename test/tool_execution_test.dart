import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/models/assistant_execution.dart';
import 'package:jarvis/tools/tool_execution.dart';
import 'package:jarvis/tools/tool_registry.dart';

void main() {
  test('blocked tools are denied before a handler can run', () async {
    var called = false;
    final executor = ToolExecutor(
      registry: ToolRegistry(),
      handlers: {
        'delete_file': (_) async {
          called = true;
          return 'deleted';
        },
      },
      verifiers: {'delete_file': (_, __) async => true},
    );

    final result = await executor.execute(
      const ToolCall(id: 'call-1', toolId: 'delete_file', arguments: {}),
      authenticated: true,
      confirmed: true,
    );

    expect(result.status, OperationStatus.denied);
    expect(result.error?.category, JarvisErrorCategory.securityBlocked);
    expect(called, isFalse);
  });

  test('registered handlers require verification for success', () async {
    final executor = ToolExecutor(
      registry: ToolRegistry(),
      handlers: {'web_search': (_) async => 'real output'},
      verifiers: {'web_search': (_, output) async => output == 'real output'},
    );

    final result = await executor.execute(
      const ToolCall(id: 'call-2', toolId: 'web_search', arguments: {}),
      authenticated: true,
      confirmed: false,
    );

    expect(result.isSuccess, isTrue);
    expect(result.output, 'real output');
  });

  test('missing handlers are reported as unsupported', () async {
    final result = await ToolExecutor(registry: ToolRegistry()).execute(
      const ToolCall(id: 'call-3', toolId: 'open_app', arguments: {}),
      authenticated: true,
      confirmed: false,
    );

    expect(result.status, OperationStatus.unsupported);
    expect(result.error?.category, JarvisErrorCategory.unsupported);
  });
}
