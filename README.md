# JARVIS — Personal AI Assistant

A production-oriented starter architecture for an Android-first personal AI assistant with Windows companion support.

## Included
- Voice-first orchestration and wake-word abstraction
- Speaker verification gate and session authentication interfaces
- Permission/capability registry with per-app policy
- Secure device pairing abstraction
- Phone ↔ Windows companion messaging interfaces
- Web search service abstraction
- Persistent memory repository interfaces with sensitive-memory guard
- Tool registry, risk classification, confirmations and audit logging
- OpenAI/Gemini/local provider adapters as interfaces (no secrets embedded)
- Automation engine abstractions
- Flutter UI shell and Android native bridge scaffolding

## Important
This package intentionally does not contain any API key. Configure providers through environment/secure platform storage later.

## Run
1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. Open the Android project in Android Studio/VS Code and configure native services.

This is a real implementation scaffold: platform-specific capabilities that require user-granted OS permissions remain explicit adapters rather than fake UI actions.
