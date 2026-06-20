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
  [
    {
      "id": "pip_blue_gear",
      "title": "Pip's Blue Gear",
      "story": "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods. He searched high and low, under leafy ferns and behind mossy rocks. With the help of a friendly ladybug named Dot, Pip found his gear glowing softly near a sparkling stream. Dot helped him pop it back in, and Pip's gears turned happily once more!",
      "quizzes": [
        {
          "question": "What colour was Pip's lost gear?",
          "options": ["Red", "Green", "Blue", "Yellow"],
          "answer": "Blue"
        },
        {
          "question": "What kind of creature or object is Pip?",
          "options": ["A magical fairy", "A clever little robot", "A wild animal", "A flying spaceship"],
          "answer": "A clever little robot"
        },
        {
          "question": "Where did Pip lose his blue gear?",
          "options": ["On the Moon", "In the Whispering Woods", "In the deep blue ocean", "At a robot school"],
          "answer": "In the Whispering Woods"
        },
        {
          "question": "How did the story describe the lost gear?",
          "options": ["Rusty and old", "Shiny and blue", "Heavy and golden", "Tiny and green"],
          "answer": "Shiny and blue"
        },
        {
          "question": "What adjective was used to describe Pip?",
          "options": ["Silly", "Clever", "Grumpy", "Sleepy"],
          "answer": "Clever"
        }
      ],
      "pipTheme": {
        "primaryColor": "#E0E7FF",
        "secondaryColor": "#4FC3F7",
        "headColor": "#F5F3FF",
        "gearColor": "#4FC3F7",
        "antennaColor": "#4FC3F7",
        "backgroundColors": ["#F5F3FF", "#E0E7FF", "#EEF2FF"],
        "emoji": "⚙️"
      }
    }
  ]
  ''';
}
