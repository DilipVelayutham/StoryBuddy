import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_buddy/features/story_buddy/data/models/story_model.dart';
import 'package:story_buddy/features/story_buddy/data/models/quiz_model.dart';
import 'package:story_buddy/features/story_buddy/presentation/providers/story_provider.dart';
import 'package:story_buddy/features/story_buddy/presentation/providers/quiz_provider.dart';

void main() {
  group('Story and Quiz JSON Parsing Tests', () {
    test('Should parse 3-option JSON quiz correctly', () {
      const json3Options = '''
      {
        "story": "Once upon a time...",
        "quiz": {
          "question": "What is the answer?",
          "options": ["A", "B", "C"],
          "answer": "B"
        }
      }
      ''';

      final decoded = json.decode(json3Options);
      final model = StoryModel.fromJson(decoded);

      expect(model.storyText, "Once upon a time...");
      expect(model.quizzes.first.question, "What is the answer?");
      expect(model.quizzes.first.options.length, 3);
      expect(model.quizzes.first.options, ["A", "B", "C"]);
      expect(model.quizzes.first.answer, "B");
    });

    test('Should parse 4-option JSON quiz correctly', () {
      const json4Options = '''
      {
        "story": "Once upon a time...",
        "quiz": {
          "question": "What is the answer?",
          "options": ["A", "B", "C", "D"],
          "answer": "C"
        }
      }
      ''';

      final decoded = json.decode(json4Options);
      final model = StoryModel.fromJson(decoded);

      expect(model.quizzes.first.options.length, 4);
      expect(model.quizzes.first.options, ["A", "B", "C", "D"]);
    });

    test('Should parse 5-option JSON quiz correctly', () {
      const json5Options = '''
      {
        "story": "Once upon a time...",
        "quiz": {
          "question": "What is the answer?",
          "options": ["A", "B", "C", "D", "E"],
          "answer": "E"
        }
      }
      ''';

      final decoded = json.decode(json5Options);
      final model = StoryModel.fromJson(decoded);

      expect(model.quizzes.first.options.length, 5);
      expect(model.quizzes.first.options, ["A", "B", "C", "D", "E"]);
    });

    test('Should fallback gracefully on invalid or empty json structures', () {
      const jsonCorrupt = '{"story": "Text with missing quiz object"}';

      final decoded = json.decode(jsonCorrupt);
      final model = StoryModel.fromJson(decoded);

      expect(model.storyText, "Text with missing quiz object");
      expect(model.quizzes.first.question, isNotEmpty);
      expect(model.quizzes.first.options, isNotEmpty);
    });
  });

  group('Riverpod Providers State Transition Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('Initial states should be correct', () async {
      final container = ProviderContainer();
      
      // Await loadStory to allow async asset mock loading to complete
      await container.read(storyBuddyNotifierProvider.notifier).loadStory();

      final storyState = container.read(storyBuddyNotifierProvider);
      final quizState = container.read(quizNotifierProvider);

      expect(storyState.status, StoryStatus.initial);
      expect(quizState.status, QuizStatus.hidden);
      expect(quizState.attempts, 0);
    });

    test('Quiz status transition on manual reveal', () {
      final container = ProviderContainer();
      
      // Reveal quiz
      container.read(quizNotifierProvider.notifier).revealQuiz();
      final quizState = container.read(quizNotifierProvider);

      expect(quizState.status, QuizStatus.visible);
    });
  });
}
