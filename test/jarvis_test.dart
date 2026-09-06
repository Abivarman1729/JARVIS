import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/tools/tool_registry.dart';
import 'package:jarvis/models/jarvis_models.dart';

void main() {
  test('destructive actions are blocked', () {
    final tools = ToolRegistry();
    expect(tools.riskFor('delete_file'), RiskLevel.blocked);
    expect(tools.riskFor('change_security_settings'), RiskLevel.blocked);
    expect(tools.riskFor('execute_payment'), RiskLevel.blocked);
  });
}
