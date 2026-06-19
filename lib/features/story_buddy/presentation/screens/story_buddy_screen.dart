import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
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
    // Confetti runs for 2 seconds on success
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pipState = ref.watch(pipStateProvider);

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
          // 1. Magical background gradient
          _buildBackgroundGradient(),

          // 2. Translucent floating blobs (for depth and glassmorphism)
          _buildBackgroundBlobs(),

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
                        // Centered PIP Character
                        Center(
                          child: PipCompanion(state: pipState),
                        ),
                        const SizedBox(height: 12),
                        
                        // Story card
                        const StoryContent(),
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

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.backgroundGradient,
        ),
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        // Coral Top-Right blob
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coralOrange.withOpacity(0.18),
            ),
          ),
        ),
        // Candy Pink Mid-Left blob
        Positioned(
          top: 280,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.candyPink.withOpacity(0.12),
            ),
          ),
        ),
        // Sunshine Yellow Bottom-Right blob
        Positioned(
          bottom: -40,
          right: -30,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sunshineYellow.withOpacity(0.18),
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
          // Logo Badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              '🤖',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          // App Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
              ),
              Text(
                AppStrings.appTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
