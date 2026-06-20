import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService();

  Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      // Setup parameters for children (slower speech, soft warm voice tone)
      await _flutterTts.setSpeechRate(0.40); 
      await _flutterTts.setPitch(1.2); // Warm and cute, not too high
      await _flutterTts.setVolume(1.0);

      // Attempt to configure standard US English accent
      await _flutterTts.setLanguage('en-US');

      try {
        final List<dynamic>? voices = await _flutterTts.getVoices;
        if (voices != null) {
          dynamic femaleVoice;
          for (var voice in voices) {
            if (voice is Map) {
              final name = voice['name']?.toString().toLowerCase() ?? '';
              final locale = voice['locale']?.toString().toLowerCase() ?? '';
              if (locale.contains('en-us') || locale.contains('en_us')) {
                if (name.contains('female') || 
                    name.contains('zira') || 
                    name.contains('samantha') || 
                    name.contains('sfg') || 
                    name.contains('lisa') || 
                    name.contains('jessica') || 
                    name.contains('wavenet-c') || 
                    name.contains('wavenet-e') || 
                    name.contains('wavenet-f')) {
                  femaleVoice = voice;
                  break;
                }
              }
            }
          }
          if (femaleVoice != null) {
            await _flutterTts.setVoice({
              "name": femaleVoice["name"],
              "locale": femaleVoice["locale"]
            });
          }
        }
      } catch (_) {}

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
