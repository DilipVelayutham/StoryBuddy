# StoryBuddy 🤖
### *Listen • Imagine • Learn*

StoryBuddy is a joyful, AI-powered storytelling companion for children aged 8–14. It is built as a highly polished, production-ready single-screen application in **Flutter** using **Riverpod** for state management, optimized to deliver a solid 60fps experience even on mid-range Android devices (~3GB RAM).

---

## 🛠️ Key Architectural Decisions & Why Flutter?

We chose **Flutter** as the development framework for the following reasons:
1. **Visual Consistency & Control**: Children's apps require custom shapes, animations, and high-fidelity layouts. Flutter's Skia/Impeller rendering engines allow us to control every pixel directly.
2. **60fps Custom Canvas Graphics**: Instead of relying on heavy raster graphics (PNGs, GIFs) or Lottie files that consume substantial memory on 3GB RAM devices, we drew our companion **PIP** entirely using the `CustomPainter` API. This runs vector path rendering directly on the GPU with minimal RAM footprint.
3. **Maturity of Riverpod**: Riverpod provides compile-safe dependency injection and granular rebuild optimizations (`ref.watch(provider.select(...))`), ensuring UI components only redraw when their specific slice of state changes.

---

## 🧠 State Machine Mappings

We decouple the application into three independent, synchronized state machines driven by Riverpod `StateNotifier`s:

### 1. Story State (`StoryBuddyState`)
*   `initial`: The story text is displayed; the narration trigger is active.
*   `loading`: Initializing the TTS engine or loading assets.
*   `playing`: TTS is actively speaking; narration highlights are active.
*   `completed`: Narration finished; transitions user to the quiz.
*   `error`: TTS failed to initialize; displays a warning but unlocks manual reading.

### 2. Quiz State (`QuizBuddyState`)
*   `hidden`: The quiz card is positioned off-screen.
*   `visible`: The quiz card slides up; answer selection is active.
*   `answering`: Answer validation is in progress (input disabled).
*   `wrongAnswer`: Shakes the card, vibrates the device, and sets PIP to thinking.
*   `correctAnswer`: Bounces PIP, plays confetti, and highlights the choice.
*   `success`: Displays the final congratulations card with a retry button.

### 3. PIP Character State (`PipState`)
*   `idle`: Gentle breathing (scale pulse) and floating (vertical translation).
*   `listening`: Attentive tilted posture and focused eye blinks.
*   `speaking`: Mouth scales vertically in sync with a loop.
*   `thinking`: Eye lenses spin; chest gear stops rotating.
*   `happy` / `celebrating`: Spin-bounces with green arching eyes and fast chest gear rotation.

---

## 🔄 Narration-to-Quiz Transitions

The transition between the narration ending and the quiz appearing is managed reactively:
1. When the user taps **"Read Me a Story"**, the `StoryBuddyNotifier` triggers `TtsService.speak()`.
2. The `TtsService` hooks into native completion listeners (`setCompletionHandler`).
3. Upon completion, the handler triggers a callback that updates the `StoryStatus` to `completed`.
4. The `StoryBuddyNotifier` reactively updates the `PipState` to `listening` and calls `QuizNotifier.revealQuiz()`.
5. The `QuizNotifier` changes the `QuizStatus` from `hidden` to `visible`, which triggers a `SlideTransition` / `FadeInTransition` on the UI, bringing the quiz card smoothly into the child's view.

---

## 📊 Data-Driven Quiz Renderer

The quiz renderer is **fully dynamic** and generated from JSON:
*   **Asset Loading**: The app reads from `assets/data/story_quiz.json` and parses it into structured `StoryModel` and `QuizModel` classes.
*   **Variable Option Layouts**: The `QuizRenderer` loops over the parsed list of options (`quiz.options.map(...)`) and renders them using flexible widgets. It automatically accommodates **3, 4, or 5 options** (or any length) without layout overflows.
*   **Different Text Lengths**: Text options use auto-wrapped, flexible constraints.
*   **Future Backend Ready**: The architecture isolates the JSON loading inside `StoryRepository`. Swapping local assets for a REST API call is as simple as changing the `loadStory()` repository implementation; no UI or domain code needs to be modified.

---

## 💾 Caching Strategy (Remote Audio Concept)

If we were to integrate a remote audio API (e.g., ElevenLabs / Amazon Polly):
1. **Hashing URL**: We would hash the input text or API request parameters to create a unique cache key (e.g., `md5(story_text)`).
2. **Local Storage Lookup**: Check if a file named `<hash_key>.mp3` exists in the local temporary directory (`path_provider`'s `getTemporaryDirectory()`).
3. **Cache Hit**: Load and play directly from the cached file.
4. **Cache Miss**: Download the audio byte stream, write it to local storage for future playbacks, and load it into the audio player.
5. **Eviction Policy**: Set a maximum cache size (e.g., 50MB) and evict the oldest files (LRU - Least Recently Used) if we exceed it.

---

## 🛠️ Audio Loading, Failures & Error Resilience

The application is built to be resilient:
*   **TTS Initialization Guard**: If native TTS fails (e.g. missing speech engines on low-end Androids), the app catches the exception, updates state to `StoryStatus.error`, shows a helpful message ("PIP is resting his voice! read along below"), and **automatically reveals the quiz** so the user is never stuck.
*   **JSON Corruption Fallback**: If the asset JSON file is corrupted or missing, `StoryRepository` catches the format error and falls back to a clean local string representation (`AppStrings.fallbackQuizJson`). If that also fails, it returns a hardcoded default model.
*   **Offline Support**: Since TTS synthesis and assets are fully on-device, the app is 100% functional without internet connectivity.

---

## ⚡ Performance Optimization for 3GB RAM Devices

To maintain a steady 60fps on modest Android hardware:
*   **CustomPainter Canvas Drawing**: Zero texture memory allocation compared to heavy animations or images. PIP is drawn as pure vector paths.
*   **Repaint Boundaries**: Wrapped the `PipCompanion` and `ConfettiWidget` inside `RepaintBoundary` widgets. This isolates their frequent visual redraws and prevents the rest of the static UI (gradient background, text cards) from being forced to redraw.
*   **Const Constructors**: Maximized the use of `const` widgets to cache visual subtrees.
*   **Ref.select Provider Consumers**: Individual widgets only consume specific parts of the state. For example, the play button only watches `storyState.status` rather than the whole `StoryBuddyState` object, avoiding redundant rebuilds.

---

## 🤖 AI Usage & Judgement Reflections

### Where AI Was Used
AI was used to:
1. Generate mathematical sine/cosine translations for PIP's breathing and floating animations.
2. Outline custom canvas path equations for drawing complex face curves and gear spokes.
3. Draft initial Riverpod boilerplate structure.

### Suggestions Rejected
*   **Using Lottie/GIFs**: The AI suggested downloading a cute robot GIF or Lottie file for PIP. We **rejected this** because on a 3GB RAM Android phone, decoding raster frames or complex Lottie vectors on every frame strains the main thread, leading to garbage collection spikes and frame drops. Custom canvas painting is much lighter.

### What Didn't Work & How It Was Resolved
*   **Path Space Bug during Test Execution**: Standard `flutter test` commands crash on Windows machines when the user's home directory contains space characters (e.g., `C:\Users\Dilip Velayutham`). The Dart native asset hook compiler fails to quote paths when compiling iOS native hooks for packages (like `objective_c` imported by `flutter_tts`).
*   **Resolution**: We isolated and verified our domain parser logic through standalone modular tests (`test/story_buddy_test.dart`) and successfully ran an Android debug build (`flutter build apk --debug`) which compiles cleanly since Android utilizes Gradle.

---

## 🏁 Submission Verification Checklist

*   [x] Feature-First Scalable Architecture
*   [x] State Management decoupled from UI via Riverpod
*   [x] Fully Data-driven Quiz Renderer (no hardcoding)
*   [x] 60fps animations (breathing, speaking mouth, rotating gear, shake)
*   [x] Graceful fallback on TTS and JSON parse errors
*   [x] Highly polished glassmorphic violet design
