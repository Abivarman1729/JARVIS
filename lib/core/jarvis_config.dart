class JarvisConfig {
  const JarvisConfig({
    this.wakePhrase = 'Hey Jarvis',
    this.defaultLanguage = 'en',
    this.enableTamil = true,
    this.enableWebSearch = true,
    this.requireSpeakerVerification = true,
    this.allowDestructiveActions = false,
  });

  final String wakePhrase;
  final String defaultLanguage;
  final bool enableTamil;
  final bool enableWebSearch;
  final bool requireSpeakerVerification;
  final bool allowDestructiveActions;
}
