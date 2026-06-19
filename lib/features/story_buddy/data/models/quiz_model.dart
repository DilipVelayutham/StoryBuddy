class QuizModel {
  final String question;
  final List<String> options;
  final String answer;

  QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    // Graceful error handling for missing/malformed fields
    final questionText = json['question'] as String? ?? 'No question provided.';
    
    final optionsRaw = json['options'];
    List<String> parsedOptions = [];
    if (optionsRaw is List) {
      parsedOptions = optionsRaw.map((e) => e.toString()).toList();
    }
    
    final answerText = json['answer'] as String? ?? '';

    return QuizModel(
      question: questionText,
      options: parsedOptions,
      answer: answerText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
    };
  }

  @override
  String toString() {
    return 'QuizModel(question: $question, options: $options, answer: $answer)';
  }
}
