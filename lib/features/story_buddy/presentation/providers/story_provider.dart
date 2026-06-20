import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/story_model.dart';
import '../../data/repositories/story_repository.dart';
import '../../../../core/services/tts_service.dart';
import 'pip_provider.dart';
import 'quiz_provider.dart';

enum StoryStatus { initial, loading, playing, completed, error }

class StoryBuddyState {
  final List<StoryModel> allStories;
  final StoryModel? story;
  final StoryModel? previousStory;
  final StoryStatus status;
  final String? errorMessage;

  StoryBuddyState({
    this.allStories = const [],
    this.story,
    this.previousStory,
    this.status = StoryStatus.initial,
    this.errorMessage,
  });

  StoryBuddyState copyWith({
    List<StoryModel>? allStories,
    StoryModel? story,
    StoryModel? previousStory,
    StoryStatus? status,
    String? errorMessage,
  }) {
    return StoryBuddyState(
      allStories: allStories ?? this.allStories,
      story: story ?? this.story,
      previousStory: previousStory ?? this.previousStory,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final storyRepositoryProvider = Provider<StoryRepository>((ref) => StoryRepository());

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
    loadStories();
  }

  Future<void> loadStories() async {
    state = state.copyWith(status: StoryStatus.loading);
    try {
      final stories = await _repository.loadStories();
      if (stories.isEmpty) {
        throw Exception("No stories loaded.");
      }
      
      // Select a random story at startup
      final random = math.Random();
      final initialStory = stories[random.nextInt(stories.length)];

      state = state.copyWith(
        allStories: stories,
        story: initialStory,
        status: StoryStatus.initial,
      );

      _setupTtsHandlers();
    } catch (e) {
      state = state.copyWith(
        status: StoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void _setupTtsHandlers() {
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
        _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
        _ref.read(quizNotifierProvider.notifier).revealQuiz();
      },
    );
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
      _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
      _ref.read(quizNotifierProvider.notifier).revealQuiz();
    }
  }

  Future<void> stopReading() async {
    await _ttsService.stop();
    state = state.copyWith(status: StoryStatus.initial);
    _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
  }

  void selectNextRandomStory() {
    if (state.allStories.isEmpty) return;
    
    stopReading();
    final random = math.Random();
    List<StoryModel> eligible = state.allStories
        .where((s) => s.id != state.story?.id)
        .toList();
    if (eligible.isEmpty) {
      eligible = state.allStories;
    }
    
    final nextStory = eligible[random.nextInt(eligible.length)];
    final previous = state.story;

    state = state.copyWith(
      previousStory: previous,
      story: nextStory,
      status: StoryStatus.initial,
    );

    _ref.read(quizNotifierProvider.notifier).reset();
    _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
  }

  void selectStory(StoryModel chosenStory) {
    stopReading();
    final previous = state.story;

    state = state.copyWith(
      previousStory: previous,
      story: chosenStory,
      status: StoryStatus.initial,
    );

    _ref.read(quizNotifierProvider.notifier).reset();
    _ref.read(pipStateProvider.notifier).updateState(PipState.idle);
  }

  void replayCurrentStory() {
    stopReading();
    state = state.copyWith(
      status: StoryStatus.initial,
    );
    _ref.read(quizNotifierProvider.notifier).reset();
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
