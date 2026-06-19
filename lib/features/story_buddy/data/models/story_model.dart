import 'quiz_model.dart';

class StoryModel {
  final String storyText;
  final List<QuizModel> quizzes;

  StoryModel({
    required this.storyText,
    required this.quizzes,
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
      storyText: text,
      quizzes: parsedQuizzes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'story': storyText,
      'quizzes': quizzes.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'StoryModel(storyText: $storyText, quizzes: $quizzes)';
  }
}
