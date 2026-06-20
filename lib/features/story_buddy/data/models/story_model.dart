import 'package:flutter/material.dart';
import 'quiz_model.dart';

class PipThemeModel {
  final String primaryColorHex;
  final String secondaryColorHex;
  final String headColorHex;
  final String gearColorHex;
  final String antennaColorHex;
  final List<String> backgroundColorsHex;
  final String emoji;

  PipThemeModel({
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.headColorHex,
    required this.gearColorHex,
    required this.antennaColorHex,
    required this.backgroundColorsHex,
    required this.emoji,
  });

  factory PipThemeModel.fromJson(Map<String, dynamic> json) {
    return PipThemeModel(
      primaryColorHex: json['primaryColor'] as String? ?? '#E0E7FF',
      secondaryColorHex: json['secondaryColor'] as String? ?? '#4FC3F7',
      headColorHex: json['headColor'] as String? ?? '#F5F3FF',
      gearColorHex: json['gearColor'] as String? ?? '#4FC3F7',
      antennaColorHex: json['antennaColor'] as String? ?? '#4FC3F7',
      backgroundColorsHex: List<String>.from(json['backgroundColors'] ?? ['#F5F3FF', '#E0E7FF', '#EEF2FF']),
      emoji: json['emoji'] as String? ?? '🤖',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColorHex,
      'secondaryColor': secondaryColorHex,
      'headColor': headColorHex,
      'gearColor': gearColorHex,
      'antennaColor': antennaColorHex,
      'backgroundColors': backgroundColorsHex,
      'emoji': emoji,
    };
  }

  Color get primaryColor => _parseColor(primaryColorHex);
  Color get secondaryColor => _parseColor(secondaryColorHex);
  Color get headColor => _parseColor(headColorHex);
  Color get gearColor => _parseColor(gearColorHex);
  Color get antennaColor => _parseColor(antennaColorHex);
  List<Color> get backgroundColors => backgroundColorsHex.map(_parseColor).toList();

  static Color _parseColor(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('0xFF$cleanHex'));
    }
    return Color(int.parse('0x$cleanHex'));
  }
}

class StoryModel {
  final String id;
  final String title;
  final String storyText;
  final List<QuizModel> quizzes;
  final PipThemeModel pipTheme;

  StoryModel({
    required this.id,
    required this.title,
    required this.storyText,
    required this.quizzes,
    required this.pipTheme,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final text = json['story'] as String? ?? 'No story text loaded.';
    
    final quizzesRaw = json['quizzes'] ?? json['quiz'];
    List<QuizModel> parsedQuizzes = [];
    
    if (quizzesRaw is List) {
      parsedQuizzes = quizzesRaw
          .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (quizzesRaw is Map<String, dynamic>) {
      parsedQuizzes = [QuizModel.fromJson(quizzesRaw)];
    }
    
    if (parsedQuizzes.isEmpty) {
      parsedQuizzes = [
        QuizModel(
          question: "What colour was Pip the Robot's lost gear?",
          options: ["Red", "Green", "Blue", "Yellow"],
          answer: "Blue",
        )
      ];
    }

    return StoryModel(
      id: json['id'] as String? ?? 'default',
      title: json['title'] as String? ?? 'Pip\'s Adventure',
      storyText: text,
      quizzes: parsedQuizzes,
      pipTheme: PipThemeModel.fromJson(json['pipTheme'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'story': storyText,
      'quizzes': quizzes.map((e) => e.toJson()).toList(),
      'pipTheme': pipTheme.toJson(),
    };
  }

  @override
  String toString() {
    return 'StoryModel(id: $id, title: $title, storyText: $storyText, quizzes: $quizzes)';
  }
}
