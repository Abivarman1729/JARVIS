class VoiceManager {
  VoiceManager({required this.speakerVerifier, required this.wakeWordDetector});
  final Future<bool> Function() speakerVerifier;
  final Future<bool> Function(String) wakeWordDetector;

  Future<bool> verifyCurrentSpeaker() => speakerVerifier();

  Future<bool> acceptsWakePhrase(String audioText) => wakeWordDetector(audioText);
}
