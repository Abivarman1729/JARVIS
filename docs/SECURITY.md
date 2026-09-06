# JARVIS Security Model

- Wake phrase is a trigger, not authentication.
- Speaker verification is required before privileged commands.
- High-risk capabilities should additionally require Android biometric/device credential authentication.
- Never accept destructive file deletion, security-setting changes, or payment execution through the normal JARVIS tool layer.
- Pair devices using mutually authenticated channels; support revocation and expiry.
- Keep secrets in OS secure storage/environment configuration, never Dart source.
- Log security-relevant decisions without storing sensitive user content by default.
