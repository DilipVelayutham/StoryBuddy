# StoryBuddy

StoryBuddy is a Flutter-based storytelling application designed for children aged 8–14. Guided by **PIP**, a friendly AI companion, children can listen to narrated stories and reinforce learning through interactive quizzes.

---

## Features

- Interactive story narration using Text-to-Speech
- Animated AI companion (PIP)
- Fully data-driven quiz engine
- Confetti and feedback animations
- Responsive and child-friendly UI
- Optimized for smooth performance on mid-range Android devices

---

## Tech Stack

- Flutter
- Riverpod
- flutter_tts
- confetti
- google_fonts

---

## Application Flow

```text
Read Story
    ↓
TTS Narration
    ↓
Quiz Appears
    ↓
Wrong Answer → Retry
    ↓
Correct Answer
    ↓
Celebration
    ↓
Menu for chosing different story
    ↓
Process continues
```

---

## Architecture Highlights

- Feature-first architecture
- Riverpod-based state management
- Separate Story, Quiz, and PIP states
- Dynamic quiz rendering from JSON
- Scalable structure for future stories and quizzes

---

## Performance & Reliability

- Minimal widget rebuilds using Riverpod
- Optimized animations for 60 FPS performance
- Graceful handling of TTS failures
- Offline-friendly experience
- Lightweight implementation for low-end devices

---

## AI Usage

AI was used for:

- Architecture planning
- Riverpod boilerplate generation
- Animation ideas and optimization

---

## Developer

**Dilip Velayutham**
Assignment given by SAS Groups' Mobile App Development internship
