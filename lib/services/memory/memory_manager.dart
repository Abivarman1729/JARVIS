import '../../models/jarvis_models.dart';

abstract interface class MemoryRepository {
  Future<List<MemoryItem>> list();
  Future<void> put(MemoryItem item);
  Future<void> delete(String id);
}

class MemoryManager {
  MemoryManager(this.repository);
  final MemoryRepository repository;

  Future<bool> saveApproved(String text, {bool sensitive = false}) async {
    if (sensitive) return false;
    final item = MemoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now(),
      userApproved: true,
      sensitive: false,
    );
    await repository.put(item);
    return true;
  }

  Future<List<MemoryItem>> all() => repository.list();
}
