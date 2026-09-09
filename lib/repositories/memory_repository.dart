import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/jarvis_models.dart';
import '../services/memory/memory_manager.dart';

class SharedPreferencesMemoryRepository implements MemoryRepository {
  SharedPreferencesMemoryRepository(this.preferences);

  static const _key = 'jarvis.memory.v1';
  final SharedPreferences preferences;

  @override
  Future<List<MemoryItem>> list() async {
    final encoded = preferences.getStringList(_key) ?? const [];
    return encoded
        .map((value) => jsonDecode(value))
        .whereType<Map>()
        .map((value) => _fromJson(Map<String, Object?>.from(value)))
        .toList(growable: false);
  }

  @override
  Future<void> put(MemoryItem item) async {
    if (item.sensitive) {
      throw StateError('Sensitive memory requires an encrypted repository.');
    }
    final items = await list();
    final updated = [
      for (final current in items)
        if (current.id != item.id) current,
      item,
    ];
    final saved = await preferences.setStringList(
      _key,
      updated.map((value) => jsonEncode(_toJson(value))).toList(),
    );
    if (!saved) {
      throw StateError('Memory could not be persisted.');
    }
  }

  @override
  Future<void> delete(String id) async {
    final items = await list();
    final saved = await preferences.setStringList(
      _key,
      items
          .where((item) => item.id != id)
          .map((value) => jsonEncode(_toJson(value)))
          .toList(),
    );
    if (!saved) {
      throw StateError('Memory could not be deleted.');
    }
  }

  Future<void> clear() async {
    final cleared = await preferences.remove(_key);
    if (!cleared && preferences.containsKey(_key)) {
      throw StateError('Memory could not be cleared.');
    }
  }

  Map<String, Object?> _toJson(MemoryItem item) => {
        'id': item.id,
        'text': item.text,
        'createdAt': item.createdAt.toIso8601String(),
        'userApproved': item.userApproved,
        'sensitive': item.sensitive,
      };

  MemoryItem _fromJson(Map<String, Object?> value) => MemoryItem(
        id: value['id']! as String,
        text: value['text']! as String,
        createdAt: DateTime.parse(value['createdAt']! as String),
        userApproved: value['userApproved']! as bool,
        sensitive: value['sensitive'] as bool? ?? false,
      );
}
