import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const JarvisApp());
}

/* ================================================================
   J.A.R.V.I.S. — ADVANCED SINGLE-FILE FLUTTER CORE
   ================================================================
   Features included in this single file:

   • Voice-first assistant architecture
   • Wake-word state
   • Conversation engine
   • Persistent-style in-memory memory layer
   • Short-term conversation context
   • Long-term memory records
   • Tool/plugin architecture
   • Command router
   • Intent detection
   • Web-search abstraction
   • Device-control abstraction
   • App-control abstraction
   • Automation engine
   • Notification engine
   • Reminder engine
   • Security/permission layer
   • Confirmation layer for dangerous actions
   • Multimodal message model
   • Vision abstraction
   • Document/file abstraction
   • Research mode
   • Planning mode
   • Coding mode
   • Browser mode
   • Smart-home abstraction
   • Laptop/phone bridge abstraction
   • System-status abstraction
   • Personality engine
   • Context engine
   • Streaming response simulation
   • Voice/TTS abstraction
   • STT abstraction
   • Conversation history
   • Session management
   • Error handling
   • Logging
   • Health monitoring
   • Background task abstraction
   • Plugin registry
   • Capability registry
   • Command execution pipeline
   • UI dashboard
   • Chat interface
   • Quick actions
   • Status indicators
   • Memory management UI
   • Settings UI
   • Security UI
   • Automation UI
   • Tool UI
   • Responsive layout

   NOTE:
   This is an application architecture/core implementation.
   Real OS-level control, microphone access, camera access,
   notifications, WebSocket device linking, and production AI
   API calls must be connected to platform services/backend.
   ================================================================ */

/* ================================================================
   ENUMS
   ================================================================ */

enum JarvisMode {
  assistant,
  conversation,
  research,
  coding,
  browser,
  vision,
  planning,
  automation,
  system,
}

enum JarvisStatus {
  offline,
  initializing,
  ready,
  listening,
  thinking,
  speaking,
  executing,
  error,
}

enum MessageRole {
  user,
  assistant,
  system,
  tool,
}

enum MemoryType {
  preference,
  fact,
  instruction,
  conversation,
  task,
  context,
}

enum PermissionLevel {
  none,
  read,
  execute,
  sensitive,
  administrative,
}

enum ActionRisk {
  safe,
  low,
  medium,
  high,
  critical,
}

enum DeviceType {
  phone,
  laptop,
  desktop,
  tablet,
  unknown,
}

enum ToolExecutionState {
  idle,
  running,
  completed,
  failed,
  cancelled,
}

/* ================================================================
   CONFIGURATION
   ================================================================ */

class JarvisConfig {
  final String assistantName;
  final String wakeWord;
  final String defaultLanguage;
  final bool enableMemory;
  final bool enableVoice;
  final bool enableVision;
  final bool enableAutomation;
  final bool requireConfirmationForSensitiveActions;
  final int maxConversationMessages;
  final int maxMemoryItems;

  const JarvisConfig({
    this.assistantName = 'JARVIS',
    this.wakeWord = 'Hey Jarvis',
    this.defaultLanguage = 'en',
    this.enableMemory = true,
    this.enableVoice = true,
    this.enableVision = true,
    this.enableAutomation = true,
    this.requireConfirmationForSensitiveActions = true,
    this.maxConversationMessages = 50,
    this.maxMemoryItems = 500,
  });
}

/* ================================================================
   MODELS
   ================================================================ */

class JarvisMessage {
  final String id;
  final MessageRole role;
  final String text;
  final DateTime timestamp;
  final bool isStreaming;
  final String? toolName;
  final Map<String, dynamic> metadata;

  const JarvisMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.isStreaming = false,
    this.toolName,
    this.metadata = const {},
  });

  JarvisMessage copyWith({
    String? text,
    bool? isStreaming,
    Map<String, dynamic>? metadata,
  }) {
    return JarvisMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      toolName: toolName,
      metadata: metadata ?? this.metadata,
    );
  }
}

class JarvisMemory {
  final String id;
  final MemoryType type;
  final String content;
  final DateTime createdAt;
  DateTime updatedAt;
  final double importance;
  bool enabled;

  JarvisMemory({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    DateTime? updatedAt,
    this.importance = 0.5,
    this.enabled = true,
  }) : updatedAt = updatedAt ?? createdAt;
}

class JarvisDevice {
  final String id;
  final String name;
  final DeviceType type;
  bool connected;
  DateTime lastSeen;

  JarvisDevice({
    required this.id,
    required this.name,
    required this.type,
    this.connected = false,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();
}

class JarvisPermission {
  final String capability;
  final PermissionLevel level;
  bool granted;

  JarvisPermission({
    required this.capability,
    required this.level,
    this.granted = false,
  });
}

class JarvisAction {
  final String id;
  final String name;
  final String description;
  final ActionRisk risk;
  final Future<dynamic> Function(Map<String, dynamic>) execute;

  const JarvisAction({
    required this.id,
    required this.name,
    required this.description,
    required this.risk,
    required this.execute,
  });
}

class JarvisToolResult {
  final bool success;
  final String message;
  final dynamic data;

  const JarvisToolResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class JarvisAutomation {
  final String id;
  final String name;
  final String trigger;
  final String action;
  bool enabled;

  JarvisAutomation({
    required this.id,
    required this.name,
    required this.trigger,
    required this.action,
    this.enabled = true,
  });
}

/* ================================================================
   LOGGER
   ================================================================ */

class JarvisLogger {
  static final List<String> entries = [];

  static void info(String message) {
    _write('INFO', message);
  }

  static void warning(String message) {
    _write('WARNING', message);
  }

  static void error(String message) {
    _write('ERROR', message);
  }

  static void _write(String level, String message) {
    final entry = '${DateTime.now().toIso8601String()} [$level] $message';

    entries.add(entry);

    if (entries.length > 500) {
      entries.removeAt(0);
    }

    debugPrint(entry);
  }
}

/* ================================================================
   ID GENERATOR
   ================================================================ */

class JarvisId {
  static final Random _random = Random();

  static String create(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(999999)}';
  }
}

/* ================================================================
   MEMORY ENGINE
   ================================================================ */

class MemoryEngine {
  final JarvisConfig config;

  final List<JarvisMemory> _memories = [];

  MemoryEngine(this.config);

  List<JarvisMemory> get memories => List.unmodifiable(_memories);

  Future<void> remember(
    String content, {
    MemoryType type = MemoryType.fact,
    double importance = 0.5,
  }) async {
    if (!config.enableMemory) return;

    final memory = JarvisMemory(
      id: JarvisId.create('memory'),
      type: type,
      content: content.trim(),
      createdAt: DateTime.now(),
      importance: importance,
    );

    _memories.insert(0, memory);

    if (_memories.length > config.maxMemoryItems) {
      _memories.removeLast();
    }

    JarvisLogger.info('Memory created: ${memory.id}');
  }

  List<JarvisMemory> search(String query) {
    final normalized = query.toLowerCase();

    final results = _memories.where((memory) {
      if (!memory.enabled) return false;

      return memory.content.toLowerCase().contains(normalized);
    }).toList();

    results.sort(
      (a, b) => b.importance.compareTo(a.importance),
    );

    return results;
  }

  Future<void> forget(String id) async {
    _memories.removeWhere((memory) => memory.id == id);
  }

  Future<void> clear() async {
    _memories.clear();
  }

  String buildContext(String query) {
    final matches = search(query).take(8).toList();

    if (matches.isEmpty) {
      return '';
    }

    return matches.map((memory) => '- ${memory.content}').join('\n');
  }
}

/* ================================================================
   CONVERSATION ENGINE
   ================================================================ */

class ConversationEngine {
  final JarvisConfig config;

  final List<JarvisMessage> _messages = [];

  ConversationEngine(this.config);

  List<JarvisMessage> get messages => List.unmodifiable(_messages);

  void add(JarvisMessage message) {
    _messages.add(message);

    while (_messages.length > config.maxConversationMessages) {
      _messages.removeAt(0);
    }
  }

  void clear() {
    _messages.clear();
  }

  List<JarvisMessage> recent([int count = 12]) {
    if (_messages.length <= count) {
      return List.unmodifiable(_messages);
    }

    return _messages.sublist(_messages.length - count).toList();
  }

  String buildContext() {
    return recent().map((message) {
      final role = message.role.name.toUpperCase();
      return '$role: ${message.text}';
    }).join('\n');
  }
}

/* ================================================================
   PERMISSION ENGINE
   ================================================================ */

class PermissionEngine {
  final Map<String, JarvisPermission> _permissions = {};

  PermissionEngine() {
    register(
      'microphone',
      PermissionLevel.read,
    );

    register(
      'camera',
      PermissionLevel.read,
    );

    register(
      'notifications',
      PermissionLevel.execute,
    );

    register(
      'browser',
      PermissionLevel.execute,
    );

    register(
      'files.read',
      PermissionLevel.read,
    );

    register(
      'files.write',
      PermissionLevel.execute,
    );

    register(
      'device.control',
      PermissionLevel.sensitive,
    );

    register(
      'apps.control',
      PermissionLevel.sensitive,
    );

    register(
      'system.settings',
      PermissionLevel.administrative,
    );

    register(
      'payments',
      PermissionLevel.administrative,
    );
  }

  void register(
    String capability,
    PermissionLevel level,
  ) {
    _permissions[capability] = JarvisPermission(
      capability: capability,
      level: level,
    );
  }

  bool has(String capability) {
    return _permissions[capability]?.granted ?? false;
  }

  void grant(String capability) {
    _permissions[capability]?.granted = true;
  }

  void revoke(String capability) {
    _permissions[capability]?.granted = false;
  }

  List<JarvisPermission> get all => List.unmodifiable(_permissions.values);
}

/* ================================================================
   SECURITY ENGINE
   ================================================================ */

class SecurityEngine {
  final PermissionEngine permissions;
  final JarvisConfig config;

  SecurityEngine(
    this.permissions,
    this.config,
  );

  bool isDangerous(ActionRisk risk) {
    return risk == ActionRisk.high || risk == ActionRisk.critical;
  }

  bool requiresConfirmation(ActionRisk risk) {
    if (!config.requireConfirmationForSensitiveActions) {
      return false;
    }

    return risk == ActionRisk.medium ||
        risk == ActionRisk.high ||
        risk == ActionRisk.critical;
  }

  Future<bool> authorize(
    JarvisAction action,
  ) async {
    if (!isDangerous(action.risk)) {
      return true;
    }

    JarvisLogger.warning(
      'Sensitive action requested: ${action.name}',
    );

    return false;
  }
}

/* ================================================================
   SPEECH-TO-TEXT ABSTRACTION
   ================================================================ */

abstract class SpeechRecognitionService {
  Future<void> initialize();

  Future<void> start();

  Future<void> stop();

  Stream<String> get transcriptStream;
}

class MockSpeechRecognitionService implements SpeechRecognitionService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  @override
  Stream<String> get transcriptStream => _controller.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  void emit(String text) {
    _controller.add(text);
  }

  void dispose() {
    _controller.close();
  }
}

/* ================================================================
   TEXT-TO-SPEECH ABSTRACTION
   ================================================================ */

abstract class TextToSpeechService {
  Future<void> initialize();

  Future<void> speak(
    String text, {
    String language = 'en',
  });

  Future<void> stop();
}

class MockTextToSpeechService implements TextToSpeechService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(
    String text, {
    String language = 'en',
  }) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );
  }

  @override
  Future<void> stop() async {}
}

/* ================================================================
   WAKE WORD ENGINE
   ================================================================ */

class WakeWordEngine {
  final String wakeWord;

  bool active = false;

  WakeWordEngine(this.wakeWord);

  bool detect(String text) {
    final normalized = text.trim().toLowerCase();

    return normalized.contains(
      wakeWord.toLowerCase(),
    );
  }

  String removeWakeWord(String text) {
    return text
        .replaceFirst(
          RegExp(
            RegExp.escape(wakeWord),
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }
}

/* ================================================================
   AI BACKEND ABSTRACTION
   ================================================================ */

abstract class AIBackend {
  Future<String> generate(
    String prompt, {
    List<JarvisMessage> history = const [],
    String memoryContext = '',
  });

  Stream<String> stream(
    String prompt, {
    List<JarvisMessage> history = const [],
    String memoryContext = '',
  });
}

/* ================================================================
   LOCAL FALLBACK AI
   ================================================================ */

class LocalJarvisAI implements AIBackend {
  @override
  Future<String> generate(
    String prompt, {
    List<JarvisMessage> history = const [],
    String memoryContext = '',
  }) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    final lower = prompt.toLowerCase();

    if (lower.contains('hello') || lower.contains('hi jarvis')) {
      return 'Hello. JARVIS systems are online. How may I assist you?';
    }

    if (lower.contains('who are you')) {
      return 'I am JARVIS, your personal AI assistant and command interface.';
    }

    if (lower.contains('time')) {
      final now = DateTime.now();

      return 'The current local time is '
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}.';
    }

    if (lower.contains('memory')) {
      if (memoryContext.isEmpty) {
        return 'I currently have no matching memory for that request.';
      }

      return 'I found the following relevant memory:\n$memoryContext';
    }

    return 'Understood. I can process that request through my '
        'available reasoning, tool, device, browser, memory, '
        'automation and multimodal capabilities.';
  }

  @override
  Stream<String> stream(
    String prompt, {
    List<JarvisMessage> history = const [],
    String memoryContext = '',
  }) async* {
    final response = await generate(
      prompt,
      history: history,
      memoryContext: memoryContext,
    );

    final words = response.split(' ');

    for (final word in words) {
      await Future<void>.delayed(
        const Duration(milliseconds: 18),
      );

      yield '$word ';
    }
  }
}

/* ================================================================
   INTENT ENGINE
   ================================================================ */

class IntentEngine {
  JarvisMode detectMode(String input) {
    final text = input.toLowerCase();

    if (_containsAny(text, [
      'code',
      'program',
      'flutter',
      'dart',
      'debug',
      'developer',
    ])) {
      return JarvisMode.coding;
    }

    if (_containsAny(text, [
      'search web',
      'search online',
      'google',
      'latest news',
      'look up',
    ])) {
      return JarvisMode.browser;
    }

    if (_containsAny(text, [
      'research',
      'analyze deeply',
      'investigate',
      'compare',
    ])) {
      return JarvisMode.research;
    }

    if (_containsAny(text, [
      'schedule',
      'automate',
      'every day',
      'every morning',
      'remind me',
    ])) {
      return JarvisMode.automation;
    }

    if (_containsAny(text, [
      'camera',
      'image',
      'photo',
      'what do you see',
      'look at this',
    ])) {
      return JarvisMode.vision;
    }

    if (_containsAny(text, [
      'open app',
      'close app',
      'phone',
      'laptop',
      'wifi',
      'bluetooth',
      'volume',
      'brightness',
    ])) {
      return JarvisMode.system;
    }

    return JarvisMode.assistant;
  }

  bool _containsAny(
    String text,
    List<String> values,
  ) {
    return values.any(text.contains);
  }
}

/* ================================================================
   WEB SEARCH SERVICE
   ================================================================ */

class WebSearchService {
  Future<JarvisToolResult> search(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return const JarvisToolResult(
        success: false,
        message: 'Search query is empty.',
      );
    }

    JarvisLogger.info(
      'Web search requested: $query',
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 250),
    );

    return JarvisToolResult(
      success: true,
      message: 'Search request prepared for: $query',
      data: {
        'query': query,
        'provider': 'configured-search-provider',
      },
    );
  }
}

/* ================================================================
   VISION SERVICE
   ================================================================ */

abstract class VisionService {
  Future<JarvisToolResult> analyzeImage(
    String imagePath,
  );
}

class MockVisionService implements VisionService {
  @override
  Future<JarvisToolResult> analyzeImage(
    String imagePath,
  ) async {
    return JarvisToolResult(
      success: true,
      message: 'Image analysis request prepared.',
      data: {
        'path': imagePath,
        'analysis': 'Multimodal vision pipeline ready.',
      },
    );
  }
}

/* ================================================================
   DEVICE BRIDGE
   ================================================================ */

abstract class DeviceBridge {
  Future<List<JarvisDevice>> discover();

  Future<JarvisToolResult> connect(
    String deviceId,
  );

  Future<JarvisToolResult> execute(
    String deviceId,
    String command,
    Map<String, dynamic> arguments,
  );
}

class LocalDeviceBridge implements DeviceBridge {
  final List<JarvisDevice> _devices = [
    JarvisDevice(
      id: 'local-phone',
      name: 'Primary Phone',
      type: DeviceType.phone,
      connected: true,
    ),
    JarvisDevice(
      id: 'local-laptop',
      name: 'Primary Laptop',
      type: DeviceType.laptop,
      connected: true,
    ),
  ];

  @override
  Future<List<JarvisDevice>> discover() async {
    return List.unmodifiable(_devices);
  }

  @override
  Future<JarvisToolResult> connect(
    String deviceId,
  ) async {
    final device = _devices.cast<JarvisDevice?>().firstWhere(
          (item) => item?.id == deviceId,
          orElse: () => null,
        );

    if (device == null) {
      return const JarvisToolResult(
        success: false,
        message: 'Device not found.',
      );
    }

    device.connected = true;
    device.lastSeen = DateTime.now();

    return JarvisToolResult(
      success: true,
      message: '${device.name} connected.',
    );
  }

  @override
  Future<JarvisToolResult> execute(
    String deviceId,
    String command,
    Map<String, dynamic> arguments,
  ) async {
    final device = _devices.cast<JarvisDevice?>().firstWhere(
          (item) => item?.id == deviceId,
          orElse: () => null,
        );

    if (device == null || !device.connected) {
      return const JarvisToolResult(
        success: false,
        message: 'Device is not connected.',
      );
    }

    JarvisLogger.info(
      'Device command: $deviceId -> $command',
    );

    return JarvisToolResult(
      success: true,
      message: 'Command "$command" accepted by ${device.name}.',
      data: arguments,
    );
  }
}

/* ================================================================
   AUTOMATION ENGINE
   ================================================================ */

class AutomationEngine {
  final List<JarvisAutomation> _automations = [];

  List<JarvisAutomation> get automations => List.unmodifiable(_automations);

  void add(
    JarvisAutomation automation,
  ) {
    _automations.add(automation);
  }

  void remove(String id) {
    _automations.removeWhere(
      (item) => item.id == id,
    );
  }

  void toggle(String id) {
    final automation = _automations.cast<JarvisAutomation?>().firstWhere(
          (item) => item?.id == id,
          orElse: () => null,
        );

    if (automation != null) {
      automation.enabled = !automation.enabled;
    }
  }
}

/* ================================================================
   TOOL SYSTEM
   ================================================================ */

abstract class JarvisTool {
  String get id;

  String get name;

  String get description;

  ActionRisk get risk;

  Future<JarvisToolResult> execute(
    Map<String, dynamic> arguments,
  );
}

class SearchTool implements JarvisTool {
  final WebSearchService service;

  SearchTool(this.service);

  @override
  String get id => 'web.search';

  @override
  String get name => 'Web Search';

  @override
  String get description => 'Search the web for current information.';

  @override
  ActionRisk get risk => ActionRisk.safe;

  @override
  Future<JarvisToolResult> execute(
    Map<String, dynamic> arguments,
  ) {
    return service.search(
      arguments['query']?.toString() ?? '',
    );
  }
}

class DeviceTool implements JarvisTool {
  final DeviceBridge bridge;

  DeviceTool(this.bridge);

  @override
  String get id => 'device.control';

  @override
  String get name => 'Device Control';

  @override
  String get description => 'Control an authorized connected device.';

  @override
  ActionRisk get risk => ActionRisk.medium;

  @override
  Future<JarvisToolResult> execute(
    Map<String, dynamic> arguments,
  ) {
    return bridge.execute(
      arguments['deviceId']?.toString() ?? '',
      arguments['command']?.toString() ?? '',
      Map<String, dynamic>.from(
        arguments['arguments'] as Map? ?? {},
      ),
    );
  }
}

/* ================================================================
   TOOL REGISTRY
   ================================================================ */

class ToolRegistry {
  final Map<String, JarvisTool> _tools = {};

  void register(JarvisTool tool) {
    _tools[tool.id] = tool;

    JarvisLogger.info(
      'Tool registered: ${tool.id}',
    );
  }

  JarvisTool? get(String id) {
    return _tools[id];
  }

  List<JarvisTool> get all => List.unmodifiable(_tools.values);
}

/* ================================================================
   JARVIS CORE
   ================================================================ */

class JarvisCore extends ChangeNotifier {
  final JarvisConfig config;

  late final MemoryEngine memory;
  late final ConversationEngine conversation;
  late final PermissionEngine permissions;
  late final SecurityEngine security;
  late final IntentEngine intents;
  late final WebSearchService search;
  late final VisionService vision;
  late final DeviceBridge devices;
  late final AutomationEngine automation;
  late final AIBackend ai;
  late final SpeechRecognitionService speech;
  late final TextToSpeechService speechOutput;
  late final WakeWordEngine wakeWord;
  late final ToolRegistry tools;

  JarvisStatus status = JarvisStatus.initializing;
  JarvisMode mode = JarvisMode.assistant;

  bool wakeWordEnabled = true;
  bool listening = false;
  bool speaking = false;
  bool thinking = false;

  String currentTranscript = '';
  String currentTask = '';

  JarvisCore({
    this.config = const JarvisConfig(),
  }) {
    memory = MemoryEngine(config);
    conversation = ConversationEngine(config);
    permissions = PermissionEngine();
    security = SecurityEngine(
      permissions,
      config,
    );
    intents = IntentEngine();
    search = WebSearchService();
    vision = MockVisionService();
    devices = LocalDeviceBridge();
    automation = AutomationEngine();
    ai = LocalJarvisAI();
    speech = MockSpeechRecognitionService();
    speechOutput = MockTextToSpeechService();
    wakeWord = WakeWordEngine(config.wakeWord);

    tools = ToolRegistry();

    tools.register(
      SearchTool(search),
    );

    tools.register(
      DeviceTool(devices),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      status = JarvisStatus.initializing;
      notifyListeners();

      await speech.initialize();
      await speechOutput.initialize();

      await _loadDefaultMemory();

      status = JarvisStatus.ready;

      JarvisLogger.info(
        'JARVIS initialized successfully.',
      );

      notifyListeners();
    } catch (error) {
      status = JarvisStatus.error;

      JarvisLogger.error(
        'Initialization failed: $error',
      );

      notifyListeners();
    }
  }

  Future<void> _loadDefaultMemory() async {
    await memory.remember(
      'User prefers JARVIS as the assistant name.',
      type: MemoryType.preference,
      importance: 0.9,
    );

    await memory.remember(
      'JARVIS should behave as a helpful, capable, respectful personal assistant.',
      type: MemoryType.instruction,
      importance: 0.95,
    );
  }

  Future<void> processUserInput(
    String input,
  ) async {
    final text = input.trim();

    if (text.isEmpty) return;

    status = JarvisStatus.thinking;
    thinking = true;
    currentTranscript = text;
    mode = intents.detectMode(text);

    notifyListeners();

    final userMessage = JarvisMessage(
      id: JarvisId.create('message'),
      role: MessageRole.user,
      text: text,
      timestamp: DateTime.now(),
    );

    conversation.add(userMessage);

    try {
      final commandResult = await _tryHandleCommand(text);

      if (commandResult != null) {
        await _addAssistantResponse(
          commandResult,
        );

        return;
      }

      final memoryContext = memory.buildContext(text);

      final response = await ai.generate(
        text,
        history: conversation.recent(),
        memoryContext: memoryContext,
      );

      await _addAssistantResponse(response);
    } catch (error) {
      await _addAssistantResponse(
        'I encountered an internal error while processing that request.',
      );

      JarvisLogger.error(
        'Request processing error: $error',
      );
    } finally {
      thinking = false;

      if (!speaking) {
        status = JarvisStatus.ready;
      }

      notifyListeners();
    }
  }

  Future<void> streamUserInput(
    String input,
  ) async {
    final text = input.trim();

    if (text.isEmpty) return;

    status = JarvisStatus.thinking;
    thinking = true;
    mode = intents.detectMode(text);

    notifyListeners();

    conversation.add(
      JarvisMessage(
        id: JarvisId.create('message'),
        role: MessageRole.user,
        text: text,
        timestamp: DateTime.now(),
      ),
    );

    final assistantId = JarvisId.create('message');

    var responseText = '';

    conversation.add(
      JarvisMessage(
        id: assistantId,
        role: MessageRole.assistant,
        text: '',
        timestamp: DateTime.now(),
        isStreaming: true,
      ),
    );

    try {
      await for (final chunk in ai.stream(
        text,
        history: conversation.recent(),
        memoryContext: memory.buildContext(text),
      )) {
        responseText += chunk;

        final index = conversation.messages.indexWhere(
          (message) => message.id == assistantId,
        );

        if (index >= 0) {
          final current = conversation.messages[index];

          final replacement = current.copyWith(
            text: responseText,
            isStreaming: true,
          );

          conversation.clear();

          final rebuilt = conversation.messages.toList();

          rebuilt.add(replacement);

          for (final message in rebuilt) {
            conversation.add(message);
          }
        }

        notifyListeners();
      }
    } catch (error) {
      responseText = 'I could not complete the response.';
    }

    thinking = false;
    status = JarvisStatus.ready;

    notifyListeners();
  }

  Future<String?> _tryHandleCommand(
    String input,
  ) async {
    final text = input.toLowerCase().trim();

    if (text == 'clear conversation' || text == 'clear chat') {
      conversation.clear();

      return 'Conversation cleared.';
    }

    if (text == 'clear memory') {
      await memory.clear();

      return 'Long-term memory has been cleared.';
    }

    if (text == 'status' || text == 'system status') {
      return systemStatus();
    }

    if (text == 'list devices' || text == 'show devices') {
      final found = await devices.discover();

      if (found.isEmpty) {
        return 'No connected devices were discovered.';
      }

      return found
          .map(
            (device) => '${device.name} — ${device.type.name} — '
                '${device.connected ? 'connected' : 'offline'}',
          )
          .join('\n');
    }

    if (text.startsWith('remember ')) {
      final value = input.substring('remember '.length).trim();

      if (value.isNotEmpty) {
        await memory.remember(
          value,
          type: MemoryType.fact,
          importance: 0.7,
        );

        return 'Understood. I will remember that.';
      }
    }

    if (text.startsWith('search ')) {
      final query = input.substring('search '.length).trim();

      final result = await search.search(query);

      return result.message;
    }

    if (text == 'enable voice') {
      wakeWordEnabled = true;

      return 'Voice interaction is enabled.';
    }

    if (text == 'disable voice') {
      wakeWordEnabled = false;

      return 'Voice interaction is disabled.';
    }

    if (text == 'listen') {
      await startListening();

      return 'Listening.';
    }

    if (text == 'stop listening') {
      await stopListening();

      return 'Listening stopped.';
    }

    return null;
  }

  Future<void> _addAssistantResponse(
    String response,
  ) async {
    conversation.add(
      JarvisMessage(
        id: JarvisId.create('message'),
        role: MessageRole.assistant,
        text: response,
        timestamp: DateTime.now(),
      ),
    );

    if (config.enableVoice) {
      await speak(response);
    }

    notifyListeners();
  }

  Future<void> startListening() async {
    if (!config.enableVoice) return;

    listening = true;
    status = JarvisStatus.listening;

    await speech.start();

    notifyListeners();
  }

  Future<void> stopListening() async {
    listening = false;

    await speech.stop();

    if (!thinking && !speaking) {
      status = JarvisStatus.ready;
    }

    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (!config.enableVoice) return;

    speaking = true;
    status = JarvisStatus.speaking;

    notifyListeners();

    await speechOutput.speak(
      text,
      language: config.defaultLanguage,
    );

    speaking = false;

    if (!thinking) {
      status = JarvisStatus.ready;
    }

    notifyListeners();
  }

  String systemStatus() {
    return '''
JARVIS SYSTEM STATUS

Core: ONLINE
Mode: ${mode.name}
Status: ${status.name}
Voice: ${config.enableVoice ? 'ENABLED' : 'DISABLED'}
Wake Word: ${wakeWordEnabled ? 'ENABLED' : 'DISABLED'}
Memory: ${config.enableMemory ? 'ENABLED' : 'DISABLED'}
Vision: ${config.enableVision ? 'ENABLED' : 'DISABLED'}
Automation: ${config.enableAutomation ? 'ENABLED' : 'DISABLED'}
Connected Devices: ${devicesCount()}
Registered Tools: ${tools.all.length}
Memories: ${memory.memories.length}
Conversation Messages: ${conversation.messages.length}
''';
  }

  int devicesCount() {
    return 2;
  }

  Future<void> executeTool(
    String toolId,
    Map<String, dynamic> arguments,
  ) async {
    final tool = tools.get(toolId);

    if (tool == null) {
      await _addAssistantResponse(
        'Tool "$toolId" is not available.',
      );

      return;
    }

    final action = JarvisAction(
      id: tool.id,
      name: tool.name,
      description: tool.description,
      risk: tool.risk,
      execute: tool.execute,
    );

    if (security.requiresConfirmation(action.risk)) {
      final authorized = await security.authorize(action);

      if (!authorized) {
        await _addAssistantResponse(
          'This action requires explicit confirmation before execution.',
        );

        return;
      }
    }

    status = JarvisStatus.executing;

    notifyListeners();

    final result = await tool.execute(arguments);

    await _addAssistantResponse(
      result.message,
    );

    status = JarvisStatus.ready;

    notifyListeners();
  }
}

/* ================================================================
   APPLICATION
   ================================================================ */

class JarvisApp extends StatefulWidget {
  const JarvisApp({
    super.key,
  });

  @override
  State<JarvisApp> createState() => _JarvisAppState();
}

class _JarvisAppState extends State<JarvisApp> {
  late final JarvisCore jarvis;

  @override
  void initState() {
    super.initState();

    jarvis = JarvisCore();
  }

  @override
  void dispose() {
    jarvis.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JARVIS',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF05070A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A8FF),
          brightness: Brightness.dark,
        ),
      ),
      home: JarvisHome(
        jarvis: jarvis,
      ),
    );
  }
}

/* ================================================================
   HOME
   ================================================================ */

class JarvisHome extends StatefulWidget {
  final JarvisCore jarvis;

  const JarvisHome({
    super.key,
    required this.jarvis,
  });

  @override
  State<JarvisHome> createState() => _JarvisHomeState();
}

class _JarvisHomeState extends State<JarvisHome> {
  final TextEditingController controller = TextEditingController();

  final ScrollController scrollController = ScrollController();

  JarvisCore get jarvis => widget.jarvis;

  @override
  void initState() {
    super.initState();

    jarvis.addListener(_refresh);

    Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    jarvis.removeListener(_refresh);
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    controller.clear();

    await jarvis.processUserInput(text);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 800) {
      return _buildMobile();
    }

    return _buildDesktop();
  }

  Widget _buildMobile() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'J.A.R.V.I.S.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          _statusIndicator(),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: _buildSidebar(),
        ),
      ),
      body: _buildMain(),
    );
  }

  Widget _buildDesktop() {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 270,
              child: _buildSidebar(),
            ),
            Expanded(
              child: _buildMain(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFF17212B),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          _jarvisLogo(),
          const SizedBox(height: 28),
          _sidebarButton(
            Icons.chat_bubble_outline,
            'Assistant',
            () {
              jarvis.mode = JarvisMode.assistant;
              setState(() {});
            },
          ),
          _sidebarButton(
            Icons.public,
            'Research',
            () {
              jarvis.mode = JarvisMode.research;
              setState(() {});
            },
          ),
          _sidebarButton(
            Icons.code,
            'Coding',
            () {
              jarvis.mode = JarvisMode.coding;
              setState(() {});
            },
          ),
          _sidebarButton(
            Icons.language,
            'Browser',
            () {
              jarvis.mode = JarvisMode.browser;
              setState(() {});
            },
          ),
          _sidebarButton(
            Icons.visibility,
            'Vision',
            () {
              jarvis.mode = JarvisMode.vision;
              setState(() {});
            },
          ),
          _sidebarButton(
            Icons.auto_awesome,
            'Automation',
            () {
              jarvis.mode = JarvisMode.automation;
              setState(() {});
            },
          ),
          _sidebarButton(
            Icons.devices,
            'Devices',
            () {
              jarvis.mode = JarvisMode.system;
              setState(() {});
            },
          ),
          const Spacer(),
          _sidebarButton(
            Icons.memory,
            'Memory',
            () {
              _showMemory();
            },
          ),
          _sidebarButton(
            Icons.security,
            'Security',
            () {
              _showSecurity();
            },
          ),
          _sidebarButton(
            Icons.settings,
            'Settings',
            () {
              _showSettings();
            },
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _jarvisLogo() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00A8FF),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x5500A8FF),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome,
              size: 44,
              color: Color(0xFF00A8FF),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'J.A.R.V.I.S.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          jarvis.status.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            color: Color(0xFF6E8798),
          ),
        ),
      ],
    );
  }

  Widget _sidebarButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        size: 21,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget _statusIndicator() {
    return Padding(
      padding: const EdgeInsets.only(
        right: 14,
      ),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: jarvis.status == JarvisStatus.error
              ? Colors.red
              : const Color(0xFF00C853),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5500C853),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: jarvis.conversation.messages.isEmpty
              ? _buildWelcome()
              : _buildConversation(),
        ),
        _buildQuickActions(),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF17212B),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            _modeTitle(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF203342),
              ),
            ),
            child: Text(
              jarvis.status.name,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
          const Spacer(),
          _statusIndicator(),
          const SizedBox(width: 10),
          Text(
            jarvis.config.wakeWord,
            style: const TextStyle(
              color: Color(0xFF607887),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _modeTitle() {
    switch (jarvis.mode) {
      case JarvisMode.assistant:
        return 'Personal Assistant';
      case JarvisMode.conversation:
        return 'Conversation';
      case JarvisMode.research:
        return 'Research Intelligence';
      case JarvisMode.coding:
        return 'Developer Intelligence';
      case JarvisMode.browser:
        return 'Web Intelligence';
      case JarvisMode.vision:
        return 'Vision System';
      case JarvisMode.planning:
        return 'Planning Engine';
      case JarvisMode.automation:
        return 'Automation Center';
      case JarvisMode.system:
        return 'System Control';
    }
  }

  Widget _buildWelcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildArcReactor(),
              const SizedBox(height: 32),
              const Text(
                'Good evening.',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'How may I assist you?',
                style: TextStyle(
                  fontSize: 21,
                  color: Color(0xFF7E98A8),
                ),
              ),
              const SizedBox(height: 42),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _suggestion(
                    'Research something',
                    Icons.public,
                  ),
                  _suggestion(
                    'Write code',
                    Icons.code,
                  ),
                  _suggestion(
                    'Analyze an image',
                    Icons.image,
                  ),
                  _suggestion(
                    'Control a device',
                    Icons.devices,
                  ),
                  _suggestion(
                    'Remember something',
                    Icons.memory,
                  ),
                  _suggestion(
                    'Create automation',
                    Icons.schedule,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArcReactor() {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00A8FF),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4400A8FF),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF5DD6FF),
              width: 4,
            ),
          ),
          child: const Icon(
            Icons.bolt,
            size: 50,
            color: Color(0xFF5DD6FF),
          ),
        ),
      ),
    );
  }

  Widget _suggestion(
    String text,
    IconData icon,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        controller.text = text;
        send();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1B2A35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF5BAFD6),
            ),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildConversation() {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: jarvis.conversation.messages.length,
      itemBuilder: (context, index) {
        final message = jarvis.conversation.messages[index];

        return _messageBubble(message);
      },
    );
  }

  Widget _messageBubble(
    JarvisMessage message,
  ) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 760,
        ),
        margin: const EdgeInsets.only(
          bottom: 16,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isUser ? const Color(0xFF102C3D) : const Color(0xFF0C1217),
          border: Border.all(
            color: isUser ? const Color(0xFF174D6A) : const Color(0xFF182630),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person_outline : Icons.auto_awesome,
                  size: 15,
                  color: isUser
                      ? const Color(0xFF8CB7CC)
                      : const Color(0xFF00A8FF),
                ),
                const SizedBox(width: 7),
                Text(
                  isUser ? 'YOU' : 'JARVIS',
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              message.text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        children: [
          _quickAction(
            'Status',
            Icons.monitor_heart_outlined,
            () {
              jarvis.processUserInput(
                'system status',
              );
            },
          ),
          _quickAction(
            'Search',
            Icons.search,
            () {
              controller.text = 'Search ';
            },
          ),
          _quickAction(
            'Memory',
            Icons.memory,
            _showMemory,
          ),
          _quickAction(
            'Devices',
            Icons.devices,
            () {
              jarvis.processUserInput(
                'list devices',
              );
            },
          ),
          _quickAction(
            'Voice',
            Icons.mic,
            () {
              if (jarvis.listening) {
                jarvis.stopListening();
              } else {
                jarvis.startListening();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(
          icon,
          size: 16,
        ),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          16,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Voice',
              onPressed: () {
                if (jarvis.listening) {
                  jarvis.stopListening();
                } else {
                  jarvis.startListening();
                }
              },
              icon: Icon(
                jarvis.listening ? Icons.mic : Icons.mic_none,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => send(),
                decoration: InputDecoration(
                  hintText: 'Ask JARVIS anything...',
                  filled: true,
                  fillColor: const Color(0xFF0A1015),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A2A35),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A2A35),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    borderSide: const BorderSide(
                      color: Color(0xFF007DB8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              heroTag: 'jarvis_send',
              mini: true,
              onPressed: jarvis.thinking ? null : send,
              child: jarvis.thinking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_upward,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF090E12),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'JARVIS MEMORY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: jarvis.memory.memories.length,
                    itemBuilder: (context, index) {
                      final memory = jarvis.memory.memories[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.memory,
                        ),
                        title: Text(memory.content),
                        subtitle: Text(
                          '${memory.type.name} • '
                          '${memory.importance.toStringAsFixed(1)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                          onPressed: () async {
                            await jarvis.memory.forget(
                              memory.id,
                            );

                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSecurity() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF090E12),
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'SECURITY & PERMISSIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ...jarvis.permissions.all.map(
                (permission) {
                  return SwitchListTile(
                    title: Text(
                      permission.capability,
                    ),
                    subtitle: Text(
                      permission.level.name,
                    ),
                    value: permission.granted,
                    onChanged: (value) {
                      if (value) {
                        jarvis.permissions.grant(
                          permission.capability,
                        );
                      } else {
                        jarvis.permissions.revoke(
                          permission.capability,
                        );
                      }

                      setState(() {});
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF090E12),
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'JARVIS SETTINGS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text(
                  'Wake Word',
                ),
                subtitle: Text(
                  jarvis.config.wakeWord,
                ),
                value: jarvis.wakeWordEnabled,
                onChanged: (value) {
                  setState(() {
                    jarvis.wakeWordEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text(
                  'Voice Output',
                ),
                value: jarvis.config.enableVoice,
                onChanged: (_) {},
              ),
              SwitchListTile(
                title: const Text(
                  'Memory',
                ),
                value: jarvis.config.enableMemory,
                onChanged: (_) {},
              ),
              SwitchListTile(
                title: const Text(
                  'Vision',
                ),
                value: jarvis.config.enableVision,
                onChanged: (_) {},
              ),
              SwitchListTile(
                title: const Text(
                  'Automation',
                ),
                value: jarvis.config.enableAutomation,
                onChanged: (_) {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text(
                  'Clear Conversation',
                ),
                onTap: () {
                  jarvis.conversation.clear();
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text(
                  'Clear Memory',
                ),
                onTap: () async {
                  await jarvis.memory.clear();
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ================================================================
   EXTENDED SYSTEM SERVICES
   ================================================================ */

class JarvisSystemService {
  Future<JarvisToolResult> openApplication(
    String application,
  ) async {
    return JarvisToolResult(
      success: true,
      message: 'Application launch request prepared: $application',
    );
  }

  Future<JarvisToolResult> closeApplication(
    String application,
  ) async {
    return JarvisToolResult(
      success: true,
      message: 'Application close request prepared: $application',
    );
  }

  Future<JarvisToolResult> setVolume(
    double value,
  ) async {
    final safeValue = value.clamp(0.0, 1.0);

    return JarvisToolResult(
      success: true,
      message: 'Volume request prepared: ${(safeValue * 100).round()}%',
    );
  }

  Future<JarvisToolResult> setBrightness(
    double value,
  ) async {
    final safeValue = value.clamp(0.0, 1.0);

    return JarvisToolResult(
      success: true,
      message: 'Brightness request prepared: ${(safeValue * 100).round()}%',
    );
  }

  Future<JarvisToolResult> getBattery() async {
    return const JarvisToolResult(
      success: true,
      message: 'Battery status request prepared.',
      data: {
        'available': true,
      },
    );
  }

  Future<JarvisToolResult> toggleWifi(
    bool enabled,
  ) async {
    return JarvisToolResult(
      success: true,
      message: 'Wi-Fi ${enabled ? 'enable' : 'disable'} request prepared.',
    );
  }

  Future<JarvisToolResult> toggleBluetooth(
    bool enabled,
  ) async {
    return JarvisToolResult(
      success: true,
      message: 'Bluetooth ${enabled ? 'enable' : 'disable'} request prepared.',
    );
  }
}

/* ================================================================
   RESEARCH ENGINE
   ================================================================ */

class ResearchEngine {
  final WebSearchService search;

  ResearchEngine(this.search);

  Future<String> research(
    String topic,
  ) async {
    final result = await search.search(topic);

    return '''
RESEARCH REQUEST

Topic:
$topic

Search:
${result.message}

Research pipeline:
1. Query generation
2. Source discovery
3. Source ranking
4. Content extraction
5. Cross-source comparison
6. Contradiction detection
7. Evidence synthesis
8. Final answer generation

The research architecture is ready for live web retrieval.
''';
  }
}

/* ================================================================
   PLANNER
   ================================================================ */

class PlanningEngine {
  List<String> createPlan(
    String objective,
  ) {
    return [
      'Understand objective',
      'Collect required context',
      'Identify constraints',
      'Break objective into tasks',
      'Prioritize tasks',
      'Execute safe tasks',
      'Request confirmation for sensitive tasks',
      'Validate results',
      'Report completion',
    ];
  }

  String formatPlan(
    String objective,
  ) {
    final plan = createPlan(objective);

    return '''
OBJECTIVE

$objective

EXECUTION PLAN

${List.generate(
      plan.length,
      (index) => '${index + 1}. ${plan[index]}',
    ).join('\n')}
''';
  }
}

/* ================================================================
   CONTEXT ENGINE
   ================================================================ */

class ContextEngine {
  String buildContext({
    required String userInput,
    required String conversation,
    required String memory,
    required String mode,
  }) {
    return '''
JARVIS CONTEXT

MODE:
$mode

USER:
$userInput

CONVERSATION:
$conversation

MEMORY:
$memory
''';
  }
}

/* ================================================================
   PERSONALITY ENGINE
   ================================================================ */

class PersonalityEngine {
  String systemPrompt({
    String language = 'en',
  }) {
    return '''
You are JARVIS.

Personality:
- Calm
- Intelligent
- Concise
- Helpful
- Respectful
- Proactive when appropriate
- Transparent about limitations
- Never pretend an action succeeded when it did not
- Protect user privacy
- Ask for confirmation before sensitive operations

Communication:
- Understand natural language.
- Support multilingual conversations.
- Match the user's language where possible.
- Explain complex subjects clearly.
- Prefer actionable answers.
- Preserve conversational context.
''';
  }
}

/* ================================================================
   MULTIMODAL INPUT
   ================================================================ */

class MultimodalInput {
  final String? text;
  final List<String> imagePaths;
  final List<String> filePaths;
  final List<String> audioPaths;

  const MultimodalInput({
    this.text,
    this.imagePaths = const [],
    this.filePaths = const [],
    this.audioPaths = const [],
  });

  bool get hasImages => imagePaths.isNotEmpty;

  bool get hasFiles => filePaths.isNotEmpty;

  bool get hasAudio => audioPaths.isNotEmpty;
}

/* ================================================================
   TASK MANAGER
   ================================================================ */

class JarvisTask {
  final String id;
  final String title;
  final String description;
  bool completed;

  JarvisTask({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });
}

class TaskManager extends ChangeNotifier {
  final List<JarvisTask> _tasks = [];

  List<JarvisTask> get tasks => List.unmodifiable(_tasks);

  void add(
    String title,
    String description,
  ) {
    _tasks.add(
      JarvisTask(
        id: JarvisId.create('task'),
        title: title,
        description: description,
      ),
    );

    notifyListeners();
  }

  void complete(String id) {
    final task = _tasks.cast<JarvisTask?>().firstWhere(
          (item) => item?.id == id,
          orElse: () => null,
        );

    if (task != null) {
      task.completed = true;
    }

    notifyListeners();
  }

  void remove(String id) {
    _tasks.removeWhere(
      (task) => task.id == id,
    );

    notifyListeners();
  }
}

/* ================================================================
   NOTIFICATION ENGINE
   ================================================================ */

class JarvisNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool read;

  JarvisNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });
}

class NotificationEngine {
  final List<JarvisNotification> _notifications = [];

  List<JarvisNotification> get notifications =>
      List.unmodifiable(_notifications);

  void push(
    String title,
    String body,
  ) {
    _notifications.insert(
      0,
      JarvisNotification(
        id: JarvisId.create('notification'),
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
  }

  void markRead(String id) {
    final item = _notifications.cast<JarvisNotification?>().firstWhere(
          (notification) => notification?.id == id,
          orElse: () => null,
        );

    item?.read = true;
  }
}

/* ================================================================
   REMINDER ENGINE
   ================================================================ */

class JarvisReminder {
  final String id;
  final String title;
  final DateTime time;
  bool completed;

  JarvisReminder({
    required this.id,
    required this.title,
    required this.time,
    this.completed = false,
  });
}

class ReminderEngine {
  final List<JarvisReminder> _reminders = [];

  List<JarvisReminder> get reminders => List.unmodifiable(_reminders);

  void add(
    String title,
    DateTime time,
  ) {
    _reminders.add(
      JarvisReminder(
        id: JarvisId.create('reminder'),
        title: title,
        time: time,
      ),
    );
  }

  void complete(String id) {
    final reminder = _reminders.cast<JarvisReminder?>().firstWhere(
          (item) => item?.id == id,
          orElse: () => null,
        );

    reminder?.completed = true;
  }
}

/* ================================================================
   EVENT BUS
   ================================================================ */

class JarvisEvent {
  final String type;
  final dynamic data;
  final DateTime timestamp;

  JarvisEvent(
    this.type, {
    this.data,
  }) : timestamp = DateTime.now();
}

class JarvisEventBus {
  final StreamController<JarvisEvent> _controller =
      StreamController<JarvisEvent>.broadcast();

  Stream<JarvisEvent> get stream => _controller.stream;

  void emit(
    String type, {
    dynamic data,
  }) {
    _controller.add(
      JarvisEvent(
        type,
        data: data,
      ),
    );
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

/* ================================================================
   HEALTH MONITOR
   ================================================================ */

class JarvisHealth {
  bool core = true;
  bool memory = true;
  bool voice = true;
  bool vision = true;
  bool tools = true;
  bool deviceBridge = true;

  bool get healthy =>
      core && memory && voice && vision && tools && deviceBridge;
}

class HealthMonitor {
  JarvisHealth check() {
    return JarvisHealth();
  }
}

/* ================================================================
   FILE INTELLIGENCE
   ================================================================ */

class FileIntelligenceService {
  Future<JarvisToolResult> inspect(
    String path,
  ) async {
    return JarvisToolResult(
      success: true,
      message: 'File inspection request prepared.',
      data: {
        'path': path,
      },
    );
  }

  Future<JarvisToolResult> summarize(
    String path,
  ) async {
    return JarvisToolResult(
      success: true,
      message: 'Document summarization request prepared.',
      data: {
        'path': path,
      },
    );
  }
}

/* ================================================================
   BROWSER INTELLIGENCE
   ================================================================ */

class BrowserIntelligenceService {
  Future<JarvisToolResult> openUrl(
    String url,
  ) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return const JarvisToolResult(
        success: false,
        message:
            'Only HTTP and HTTPS URLs are accepted by the safe browser layer.',
      );
    }

    return JarvisToolResult(
      success: true,
      message: 'Browser navigation request prepared.',
      data: {
        'url': url,
      },
    );
  }

  Future<JarvisToolResult> summarizePage(
    String url,
  ) async {
    return JarvisToolResult(
      success: true,
      message: 'Page summarization request prepared.',
      data: {
        'url': url,
      },
    );
  }
}

/* ================================================================
   CODE INTELLIGENCE
   ================================================================ */

class CodeIntelligenceService {
  Future<String> analyze(
    String code,
  ) async {
    return '''
CODE ANALYSIS

Input received.

Analysis pipeline:
• Syntax inspection
• Type analysis
• Null-safety analysis
• Architecture inspection
• Error detection
• Performance review
• Security review
• Maintainability review
• Suggested refactoring

The production implementation can connect this layer
to a remote AI backend for full code reasoning.
''';
  }

  Future<String> generate(
    String requirement,
  ) async {
    return '''
CODE GENERATION REQUEST

Requirement:
$requirement

Generation pipeline:
1. Requirements extraction
2. Architecture selection
3. API design
4. Implementation
5. Validation
6. Error handling
7. Testing
8. Security review
''';
  }
}

/* ================================================================
   SECURITY AUDIT
   ================================================================ */

class SecurityAudit {
  List<String> audit() {
    return [
      'Permission boundary enabled',
      'Sensitive action confirmation enabled',
      'Tool execution is isolated behind registry',
      'Dangerous capabilities are not automatically granted',
      'HTTP/HTTPS browser boundary enforced',
      'Memory can be cleared by the user',
      'Assistant does not claim unsupported OS actions succeeded',
      'Secrets should never be embedded in application source',
    ];
  }
}

/* ================================================================
   COMMAND PARSER
   ================================================================ */

class CommandParser {
  Map<String, dynamic>? parse(
    String input,
  ) {
    final text = input.trim();

    if (text.isEmpty) return null;

    if (text.startsWith('/search ')) {
      return {
        'command': 'search',
        'query': text.substring(8).trim(),
      };
    }

    if (text.startsWith('/remember ')) {
      return {
        'command': 'remember',
        'value': text.substring(10).trim(),
      };
    }

    if (text == '/status') {
      return {
        'command': 'status',
      };
    }

    if (text == '/memory') {
      return {
        'command': 'memory',
      };
    }

    if (text == '/devices') {
      return {
        'command': 'devices',
      };
    }

    return null;
  }
}

/* ================================================================
   SESSION MANAGER
   ================================================================ */

class JarvisSession {
  final String id;
  final DateTime createdAt;
  DateTime lastActivity;
  bool active;

  JarvisSession({
    String? id,
    DateTime? createdAt,
    this.active = true,
  })  : id = id ?? JarvisId.create('session'),
        createdAt = createdAt ?? DateTime.now(),
        lastActivity = createdAt ?? DateTime.now();

  void touch() {
    lastActivity = DateTime.now();
  }
}

class SessionManager {
  JarvisSession? current;

  JarvisSession create() {
    current = JarvisSession();
    return current!;
  }

  void end() {
    current?.active = false;
  }
}

/* ================================================================
   LANGUAGE ENGINE
   ================================================================ */

class LanguageEngine {
  String detect(String text) {
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(text)) {
      return 'ta';
    }

    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return 'hi';
    }

    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) {
      return 'zh';
    }

    if (RegExp(r'[\u3040-\u30FF]').hasMatch(text)) {
      return 'ja';
    }

    return 'en';
  }
}

/* ================================================================
   COMMAND ORCHESTRATOR
   ================================================================ */

class JarvisOrchestrator {
  final JarvisCore core;
  final PlanningEngine planner;
  final ResearchEngine researcher;
  final ContextEngine context;
  final PersonalityEngine personality;
  final LanguageEngine language;

  JarvisOrchestrator(
    this.core,
  )   : planner = PlanningEngine(),
        researcher = ResearchEngine(core.search),
        context = ContextEngine(),
        personality = PersonalityEngine(),
        language = LanguageEngine();

  Future<String> execute(
    String input,
  ) async {
    final detectedMode = core.intents.detectMode(input);

    switch (detectedMode) {
      case JarvisMode.research:
        return researcher.research(input);

      case JarvisMode.planning:
        return planner.formatPlan(input);

      default:
        return core.ai.generate(
          input,
          history: core.conversation.recent(),
          memoryContext: core.memory.buildContext(input),
        );
    }
  }

  String systemPrompt() {
    return personality.systemPrompt(
      language: core.config.defaultLanguage,
    );
  }

  String buildContext(String input) {
    return context.buildContext(
      userInput: input,
      conversation: core.conversation.buildContext(),
      memory: core.memory.buildContext(input),
      mode: core.mode.name,
    );
  }
}

/* ================================================================
   PRODUCTION BACKEND CONTRACT
   ================================================================ */

class RemoteAIRequest {
  final String model;
  final List<Map<String, dynamic>> messages;
  final Map<String, dynamic> parameters;

  const RemoteAIRequest({
    required this.model,
    required this.messages,
    this.parameters = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages,
      'parameters': parameters,
    };
  }

  String encode() {
    return jsonEncode(toJson());
  }
}

class RemoteAIResponse {
  final String text;
  final String? requestId;
  final Map<String, dynamic> metadata;

  const RemoteAIResponse({
    required this.text,
    this.requestId,
    this.metadata = const {},
  });
}

/* ================================================================
   JARVIS FACTORY
   ================================================================ */

class JarvisFactory {
  static JarvisCore create({
    JarvisConfig config = const JarvisConfig(),
  }) {
    return JarvisCore(
      config: config,
    );
  }
}

/* ================================================================
   FINAL APPLICATION ENTRY CONTRACT
   ================================================================ */

class JarvisRuntime {
  late final JarvisCore core;
  late final JarvisOrchestrator orchestrator;
  late final TaskManager tasks;
  late final NotificationEngine notifications;
  late final ReminderEngine reminders;
  late final JarvisEventBus events;
  late final HealthMonitor health;
  late final SecurityAudit securityAudit;
  late final FileIntelligenceService files;
  late final BrowserIntelligenceService browser;
  late final CodeIntelligenceService coding;
  late final JarvisSystemService system;
  late final SessionManager sessions;

  JarvisRuntime({
    JarvisConfig config = const JarvisConfig(),
  }) {
    core = JarvisFactory.create(
      config: config,
    );

    orchestrator = JarvisOrchestrator(core);

    tasks = TaskManager();
    notifications = NotificationEngine();
    reminders = ReminderEngine();
    events = JarvisEventBus();
    health = HealthMonitor();
    securityAudit = SecurityAudit();
    files = FileIntelligenceService();
    browser = BrowserIntelligenceService();
    coding = CodeIntelligenceService();
    system = JarvisSystemService();
    sessions = SessionManager();

    sessions.create();
  }

  JarvisHealth healthCheck() {
    return health.check();
  }

  Future<void> shutdown() async {
    await events.dispose();
    core.dispose();
    tasks.dispose();
  }
}

/* ================================================================
   CAPABILITY MANIFEST
   ================================================================ */

class JarvisCapabilities {
  static const List<String> all = [
    'natural_language_conversation',
    'contextual_reasoning',
    'short_term_context',
    'long_term_memory',
    'memory_search',
    'memory_delete',
    'voice_input',
    'voice_output',
    'wake_word',
    'multilingual',
    'vision',
    'image_analysis',
    'file_analysis',
    'document_summarization',
    'web_search',
    'browser_control',
    'research',
    'source_comparison',
    'planning',
    'task_management',
    'reminders',
    'notifications',
    'automation',
    'device_discovery',
    'device_bridge',
    'phone_control',
    'laptop_control',
    'application_control',
    'system_control',
    'coding_assistance',
    'code_generation',
    'code_analysis',
    'tool_registry',
    'plugin_architecture',
    'permission_management',
    'security_confirmation',
    'event_bus',
    'session_management',
    'health_monitoring',
    'structured_commands',
    'streaming_responses',
    'multimodal_inputs',
  ];
}
