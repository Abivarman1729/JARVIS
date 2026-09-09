# JARVIS architecture

JARVIS is being migrated incrementally from a prototype into a verified assistant. The intended runtime boundary is:

```text
User input
  -> presentation state
  -> JarvisController
  -> orchestrator
  -> AI gateway / structured tool planner
  -> centralized security policy
  -> permission and authentication gates
  -> tool executor
  -> Android platform service or repository
  -> verification
  -> truthful result
```

## Current milestone

The Android host now uses the current Flutter embedding and has tracked Gradle configuration. Typed execution primitives are available in `lib/models/assistant_execution.dart` for assistant states, structured tool calls, operation results, and categorized errors.

The existing large prototype in `lib/main.dart` remains temporarily preserved while the authoritative execution path is migrated. It must not be treated as evidence that platform actions, voice, AI providers, persistence, or automation are implemented.

## Rules

- Security policy executes before privileged tools.
- External content is untrusted and cannot override policy.
- A successful response requires real execution and verification.
- Unsupported platform operations return an explicit unsupported/error result.
- Every new capability needs tests and evidence before it is marked complete.
