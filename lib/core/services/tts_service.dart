import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService();

  Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      // Setup parameters for children (slower speech, cute higher-pitched robot tone)
      await _flutterTts.setSpeechRate(0.42); 
      await _flutterTts.setPitch(1.4);      
      await _flutterTts.setVolume(1.0);

      // Attempt to configure standard US English accent
      await _flutterTts.setLanguage('en-US');

      _isInitialized = true;
      return true;
    } catch (e) {
      // Fallback: mark as failed, client code will handle gracefully without crashing
      _isInitialized = false;
      return false;
    }
  }

  void setHandlers({
    required Function() onStart,
    required Function() onComplete,
    required Function(String error) onError,
  }) {
    _flutterTts.setStartHandler(() {
      onStart();
    });

    _flutterTts.setCompletionHandler(() {
      onComplete();
    });

    _flutterTts.setCancelHandler(() {
      onComplete(); // Treat cancellation as completion or reset
    });

    _flutterTts.setErrorHandler((message) {
      onError(message.toString());
    });
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      final ok = await init();
      if (!ok) throw Exception("TTS Engine failed to initialize");
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }

  Future<void> pause() async {
    if (_isInitialized) {
      await _flutterTts.pause();
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
