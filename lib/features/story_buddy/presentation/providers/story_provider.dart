import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/story_model.dart';
import '../../data/repositories/story_repository.dart';
import '../../../../core/services/tts_service.dart';
import 'pip_provider.dart';
import 'quiz_provider.dart';

enum StoryStatus { initial, loading, playing, completed, error }

class StoryBuddyState {
  final StoryModel? story;
  final StoryStatus status;
  final String? errorMessage;

  StoryBuddyState({
    this.story,
    this.status = StoryStatus.initial,
    this.errorMessage,
  });

  StoryBuddyState copyWith({
    StoryModel? story,
    StoryStatus? status,
    String? errorMessage,
  }) {
    return StoryBuddyState(
      story: story ?? this.story,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Depend on repository provider
final storyRepositoryProvider = Provider<StoryRepository>((ref) => StoryRepository());

// Depend on TtsService provider
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class StoryBuddyNotifier extends StateNotifier<StoryBuddyState> {
  final Ref _ref;
  final StoryRepository _repository;
  final TtsService _ttsService;

  StoryBuddyNotifier(this._ref, this._repository, this._ttsService)
      : super(StoryBuddyState()) {
    loadStory();
  }

  Future<void> loadStory() async {
    state = state.copyWith(status: StoryStatus.loading);
    try {
      final story = await _repository.loadStory();
      state = state.copyWith(story: story, status: StoryStatus.initial);
      
      // Setup TTS handlers
      _ttsService.setHandlers(
        onStart: () {
          state = state.copyWith(status: StoryStatus.playing);
          _ref.read(pipStateProvider.notifier).updateState(PipState.speaking);
        },
        onComplete: () {
          state = state.copyWith(status: StoryStatus.completed);
          _ref.read(pipStateProvider.notifier).updateState(PipState.listening);
          _ref.read(quizNotifierProvider.notifier).revealQuiz();
        },
        onError: (err) {
          state = state.copyWith(
            status: StoryStatus.error,
            errorMessage: err,
          );
          // If TTS fails, PIP goes to idle but we still reveal the quiz card so the child can read manually!
          _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
          _ref.read(quizNotifierProvider.notifier).revealQuiz();
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: StoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> startReading() async {
    final currentStory = state.story;
    if (currentStory == null) return;

    state = state.copyWith(status: StoryStatus.loading);
    try {
      final initialized = await _ttsService.init();
      if (!initialized) {
        throw Exception("Could not initialize text-to-speech engine.");
      }
      await _ttsService.speak(currentStory.storyText);
    } catch (e) {
      state = state.copyWith(
        status: StoryStatus.error,
        errorMessage: e.toString(),
      );
      // Fallback: Reveal quiz immediately so the child isn't blocked
      _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
      _ref.read(quizNotifierProvider.notifier).revealQuiz();
    }
  }

  Future<void> stopReading() async {
    await _ttsService.stop();
    state = state.copyWith(status: StoryStatus.initial);
    _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
  }

  void reset() {
    stopReading();
    state = state.copyWith(status: StoryStatus.initial);
    _ref.read(quizNotifierProvider.notifier).reset();
    _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
  }
}

final storyBuddyNotifierProvider =
    StateNotifierProvider<StoryBuddyNotifier, StoryBuddyState>((ref) {
  final repo = ref.watch(storyRepositoryProvider);
  final tts = ref.watch(ttsServiceProvider);
  return StoryBuddyNotifier(ref, repo, tts);
});
