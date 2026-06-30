import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/story_model.dart';
import '../providers/pip_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/story_provider.dart';
import '../widgets/pip_companion.dart';
import '../widgets/quiz_renderer.dart';
import '../widgets/story_content.dart';

class StoryBuddyScreen extends ConsumerStatefulWidget {
  const StoryBuddyScreen({super.key});

  @override
  ConsumerState<StoryBuddyScreen> createState() => _StoryBuddyScreenState();
}

class _StoryBuddyScreenState extends ConsumerState<StoryBuddyScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildKidFriendlyTransition(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
      )),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.6,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pipState = ref.watch(pipStateProvider);
    final storyState = ref.watch(storyBuddyNotifierProvider);
    final activeStory = storyState.story;

    // Listen to quiz provider changes to play confetti on success
    ref.listen<QuizBuddyState>(quizNotifierProvider, (previous, next) {
      if (next.status == QuizStatus.correctAnswer &&
          (previous == null || previous.status != QuizStatus.correctAnswer)) {
        _confettiController.play();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Magical background gradient (dynamically color-transitioning)
          _buildBackgroundGradient(activeStory),

          // 2. Translucent floating blobs (dynamically color-transitioning)
          _buildBackgroundBlobs(activeStory),

          // 3. Screen content
          SafeArea(
            child: Column(
              children: [
                // Header bar
                _buildHeader(context),
                
                // Main content scrolling area
                Expanded(
                  child: SingleChildScrollView(
                     physics: const BouncingScrollPhysics(),
                     padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 24.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: [
                         // Centered PIP Character (Animated Switcher on story change)
                         AnimatedSwitcher(
                           duration: const Duration(milliseconds: 1000),
                           transitionBuilder: _buildKidFriendlyTransition,
                           child: Center(
                             key: ValueKey(activeStory?.id ?? 'none'),
                             child: PipCompanion(
                               state: pipState,
                               story: activeStory,
                             ),
                           ),
                         ),
                         const SizedBox(height: 12),
                         
                         // Story card (Animated Switcher on story change)
                         AnimatedSwitcher(
                           duration: const Duration(milliseconds: 1000),
                           transitionBuilder: _buildKidFriendlyTransition,
                           child: KeyedSubtree(
                             key: ValueKey(activeStory?.id ?? 'none'),
                             child: const StoryContent(),
                           ),
                         ),
                         const SizedBox(height: 20),
                         
                         // Dynamic JSON Quiz Renderer (Slides up when ready)
                         const QuizRenderer(),
                       ],
                     ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Confetti Celebration overlay (Centered top burst)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.sunshineYellow,
                AppColors.candyPink,
                AppColors.skyBlue,
                AppColors.mintGreen,
                AppColors.coralOrange,
                Colors.purpleAccent,
              ],
              minimumSize: const Size(12, 12),
              maximumSize: const Size(20, 20),
              numberOfParticles: 35,
              gravity: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient(StoryModel? story) {
    final colors = story?.pipTheme.backgroundColors ?? AppColors.backgroundGradient;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }

  Widget _buildBackgroundBlobs(StoryModel? story) {
    final primary = story?.pipTheme.primaryColor ?? AppColors.candyPink;
    final secondary = story?.pipTheme.secondaryColor ?? AppColors.coralOrange;
    final tertiary = story?.pipTheme.secondaryColor ?? AppColors.sunshineYellow;

    return Stack(
      children: [
        // Coral Top-Right blob
        Positioned(
          top: -60,
          right: -40,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondary.withValues(alpha: 0.18),
            ),
          ),
        ),
        // Candy Pink Mid-Left blob
        Positioned(
          top: 280,
          left: -80,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        // Sunshine Yellow Bottom-Right blob
        Positioned(
          bottom: -40,
          right: -30,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tertiary.withValues(alpha: 0.18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          // App Title
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
          ),
        ],
      ),
    );
  }
}
