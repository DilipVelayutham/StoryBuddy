import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/quiz_model.dart';
import '../models/story_model.dart';

class StoryRepository {
  Future<StoryModel> loadStory() async {
    try {
      // Load from Flutter assets bundle
      final jsonString = await rootBundle.loadString(AppStrings.quizAssetPath);
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      return StoryModel.fromJson(decoded);
    } catch (e) {
      // In case of error (e.g. Asset not found, JSON format error, missing platform channels),
      // we fall back gracefully to the standard local JSON string.
      try {
        final decodedFallback = json.decode(AppStrings.fallbackQuizJson) as Map<String, dynamic>;
        return StoryModel.fromJson(decodedFallback);
      } catch (innerException) {
        // Ultimate fallback to hardcoded model to guarantee the app never crashes
        return StoryModel(
          storyText: "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...",
          quizzes: [
            QuizModel(
              question: "What colour was Pip the Robot's lost gear?",
              options: ["Red", "Green", "Blue", "Yellow"],
              answer: "Blue",
            ),
          ],
        );
      }
    }
  }
}
