import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/models/jarvis_models.dart';
import 'package:jarvis/repositories/memory_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists and deletes approved non-sensitive memory', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesMemoryRepository(preferences);
    final item = MemoryItem(
      id: 'memory-1',
      text: 'Use concise answers.',
      createdAt: DateTime.utc(2026, 1, 1),
      userApproved: true,
    );

    await repository.put(item);
    expect((await repository.list()).single.text, item.text);

    await repository.delete(item.id);
    expect(await repository.list(), isEmpty);
  });

  test('rejects sensitive memory without encrypted storage', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesMemoryRepository(preferences);

    expect(
      () => repository.put(
        MemoryItem(
          id: 'sensitive-1',
          text: 'secret',
          createdAt: DateTime.utc(2026, 1, 1),
          userApproved: true,
          sensitive: true,
        ),
      ),
      throwsStateError,
    );
  });
}
