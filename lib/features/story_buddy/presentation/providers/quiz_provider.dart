import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'story_provider.dart';
import 'pip_provider.dart';

enum QuizStatus {
  hidden,
  visible,
  answering,
  wrongAnswer,
  correctAnswer,
  success,
}

class QuizBuddyState {
  final QuizStatus status;
  final String? selectedOption;
  final int attempts;
  final int shakeCounter; // Incremented on wrong answer to trigger shake widget rebuilds
  final int currentIndex;

  QuizBuddyState({
    this.status = QuizStatus.hidden,
    this.selectedOption,
    this.attempts = 0,
    this.shakeCounter = 0,
    this.currentIndex = 0,
  });

  QuizBuddyState copyWith({
    QuizStatus? status,
    String? selectedOption,
    int? attempts,
    int? shakeCounter,
    int? currentIndex,
  }) {
    return QuizBuddyState(
      status: status ?? this.status,
      selectedOption: selectedOption ?? this.selectedOption,
      attempts: attempts ?? this.attempts,
      shakeCounter: shakeCounter ?? this.shakeCounter,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizBuddyState> {
  final Ref _ref;

  QuizNotifier(this._ref) : super(QuizBuddyState());

  void revealQuiz() {
    state = state.copyWith(status: QuizStatus.visible);
  }

  Future<void> submitAnswer(String option) async {
    if (state.status == QuizStatus.answering ||
        state.status == QuizStatus.correctAnswer ||
        state.status == QuizStatus.success) {
      return;
    }

    state = state.copyWith(
      status: QuizStatus.answering,
      selectedOption: option,
    );

    // Get story model from story buddy provider to validate answer
    final storyState = _ref.read(storyBuddyNotifierProvider);
    final quizzes = storyState.story?.quizzes;
    if (quizzes == null || state.currentIndex >= quizzes.length) return;

    final quiz = quizzes[state.currentIndex];
    final isCorrect = quiz.answer.trim().toLowerCase() == option.trim().toLowerCase();

    if (isCorrect) {
      // Trigger haptic success feedback
      HapticFeedback.mediumImpact();
      
      state = state.copyWith(
        status: QuizStatus.correctAnswer,
        attempts: state.attempts + 1,
      );

      // Celebrate!
      _ref.read(pipStateProvider.notifier).updateState(PipState.celebrating);

      // Wait 2.5s for celebration animation & confetti, then transition
      Timer(const Duration(milliseconds: 2500), () {
        final totalQuestions = quizzes.length;
        if (state.currentIndex < totalQuestions - 1) {
          // Move to the next question
          state = state.copyWith(
            status: QuizStatus.visible,
            selectedOption: null,
            currentIndex: state.currentIndex + 1,
          );
          _ref.read(pipStateProvider.notifier).updateState(PipState.listening);
        } else {
          // Completed all questions, show final success screen
          state = state.copyWith(status: QuizStatus.success);
        }
      });
    } else {
      // Trigger haptic wrong feedback
      HapticFeedback.vibrate();

      state = state.copyWith(
        status: QuizStatus.wrongAnswer,
        attempts: state.attempts + 1,
        shakeCounter: state.shakeCounter + 1,
      );

      // PIP enters the thinking/encouraging state
      _ref.read(pipStateProvider.notifier).updateState(PipState.thinking);

      // Wait 1.5s then return to visible state so child can select again
      Timer(const Duration(milliseconds: 1500), () {
        if (state.status == QuizStatus.wrongAnswer) {
          state = state.copyWith(
            status: QuizStatus.visible,
            selectedOption: null, // clear selection for retry
          );
          _ref.read(pipStateProvider.notifier).updateState(PipState.listening);
        }
      });
    }
  }

  void reset() {
    state = QuizBuddyState();
  }
}

final quizNotifierProvider =
    StateNotifierProvider<QuizNotifier, QuizBuddyState>((ref) {
  return QuizNotifier(ref);
});
