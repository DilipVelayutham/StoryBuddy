class AppStrings {
  AppStrings._();

  static const String appName = 'StoryBuddy';
  static const String appTagline = 'Listen • Imagine • Learn';
  
  static const String readMeStory = 'Read Me a Story';
  static const String pipCompanionName = 'PIP';
  
  // TTS States
  static const String ttsPreparing = 'PIP is warming up his vocal gears... ⚙️';
  static const String ttsPlaying = 'Listen closely as PIP narrates! 🎙️';
  static const String ttsFinished = 'Amazing listening! Now let\'s try a quick quiz! 🧠';
  static const String ttsError = 'Oh no! PIP lost his voice temporarily. Read along below! 📖';
  static const String errorRetry = 'Tap to try reading again!';

  // Quiz States
  static const String selectAnswer = 'Select the best option:';
  static const String correctTitle = 'Woohoo! You got it! 🎉';
  static const String wrongTitle = 'Not quite! Give it another spin! 🌀';
  static const String successTitle = 'Sensational Job! You completed the story! 🏆';
  static const String playAgain = 'Play Again! 🔄';

  // Asset paths
  static const String quizAssetPath = 'assets/data/story_quiz.json';

  // Fallback JSON payload if assets fail to load
  static const String fallbackQuizJson = '''
  {
    "story": "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...",
    "quizzes": [
      {
        "question": "What colour was Pip the Robot's lost gear?",
        "options": ["Red", "Green", "Blue", "Yellow"],
        "answer": "Blue"
      }
    ]
  }
  ''';
}
