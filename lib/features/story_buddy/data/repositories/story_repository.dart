import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/quiz_model.dart';
import '../models/story_model.dart';

class StoryRepository {
  Future<List<StoryModel>> loadStories() async {
    try {
      // Load from Flutter assets bundle
      final jsonString = await rootBundle.loadString(AppStrings.quizAssetPath);
      final decoded = json.decode(jsonString);
      if (decoded is List) {
        return decoded.map((e) => StoryModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (decoded is Map<String, dynamic>) {
        return [StoryModel.fromJson(decoded)];
      }
      return [];
    } catch (e) {
      // In case of error (e.g. Asset not found, JSON format error, missing platform channels),
      // we fall back gracefully to the standard local JSON string.
      try {
        final decodedFallback = json.decode(AppStrings.fallbackQuizJson);
        if (decodedFallback is List) {
          return decodedFallback.map((e) => StoryModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (decodedFallback is Map<String, dynamic>) {
          return [StoryModel.fromJson(decodedFallback)];
        }
        return [];
      } catch (innerException) {
        // Ultimate fallback to hardcoded model to guarantee the app never crashes
        return [
          StoryModel(
            id: "pip_blue_gear",
            title: "Pip's Blue Gear",
            storyText: "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...",
            quizzes: [
              QuizModel(
                question: "What colour was Pip the Robot's lost gear?",
                options: ["Red", "Green", "Blue", "Yellow"],
                answer: "Blue",
              ),
            ],
            pipTheme: PipThemeModel(
              primaryColorHex: "#E0E7FF",
              secondaryColorHex: "#4FC3F7",
              headColorHex: "#F5F3FF",
              gearColorHex: "#4FC3F7",
              antennaColorHex: "#4FC3F7",
              backgroundColorsHex: ["#F5F3FF", "#E0E7FF", "#EEF2FF"],
              emoji: "⚙️",
            ),
          )
        ];
      }
    }
  }
}
