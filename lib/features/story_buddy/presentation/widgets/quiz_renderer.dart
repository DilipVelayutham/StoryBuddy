import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/shake_transition.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/animations/fade_in_transition.dart';
import '../../../../shared/widgets/bubbly_button.dart';
import '../../data/models/story_model.dart';
import '../providers/quiz_provider.dart';
import '../providers/story_provider.dart';
import '../providers/pip_provider.dart';
import 'glass_card.dart';
import 'pip_companion.dart';

class QuizRenderer extends ConsumerWidget {
  const QuizRenderer({super.key});

  void _showChooseStoryDialog(BuildContext context, WidgetRef ref, List<StoryModel> stories) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5F3FF),
                  Color(0xFFE0E7FF),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🗺️',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Choose Story!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Grid of 2x5 stories
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      final story = stories[index];
                      final theme = story.pipTheme;
                      
                      return InkWell(
                        onTap: () {
                          ref.read(storyBuddyNotifierProvider.notifier).selectStory(story);
                          Navigator.of(dialogContext).pop();
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.primaryColor.withValues(alpha: 0.2),
                                theme.secondaryColor.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.primaryColor.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // PIP's unique still matching the vibe!
                              SizedBox(
                                height: 48,
                                width: 48,
                                child: CustomPaint(
                                  size: const Size(44, 44),
                                  painter: PipPainter(
                                    state: PipState.happy,
                                    mouthOpen: 0.0,
                                    gearRotation: 0.0,
                                    theme: theme,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Title
                              Text(
                                story.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Emoji
                              Text(
                                theme.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Close button
                BubblyButton.text(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  label: 'Close ❌',
                  backgroundColor: AppColors.coralOrange,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizNotifierProvider);
    final storyState = ref.watch(storyBuddyNotifierProvider);
    
    // If hidden, render an empty shrinking box
    if (quizState.status == QuizStatus.hidden) {
      return const SizedBox.shrink();
    }

    final quizzes = storyState.story?.quizzes;
    if (quizzes == null || quizState.currentIndex >= quizzes.length) {
      return const SizedBox.shrink();
    }
    final quiz = quizzes[quizState.currentIndex];

    // Success State Dashboard layout
    if (quizState.status == QuizStatus.success) {
      final storyNotifier = ref.read(storyBuddyNotifierProvider.notifier);
      
      return FadeInTransition(
        child: GlassCard(
          borderColor: AppColors.successGreen.withValues(alpha: 0.5),
          color: AppColors.successGreen.withValues(alpha: 0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.successTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryDeepPurple,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You completed the story in ${quizState.attempts} attempt(s)! Keep it up!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 24),
              BubblyButton.text(
                onPressed: () {
                  storyNotifier.selectNextRandomStory();
                },
                label: 'Play Next Story',
                backgroundColor: AppColors.primaryPurple,
                icon: Icons.skip_next_rounded,
              ),
              const SizedBox(height: 12),
              BubblyButton.text(
                onPressed: () {
                  _showChooseStoryDialog(context, ref, storyState.allStories);
                },
                label: 'Choose Story',
                backgroundColor: AppColors.skyBlue,
                icon: Icons.grid_view_rounded,
              ),
              const SizedBox(height: 12),
              BubblyButton.text(
                onPressed: () {
                  storyNotifier.replayCurrentStory();
                },
                label: 'Play Again',
                backgroundColor: AppColors.mintGreen,
                icon: Icons.replay_rounded,
              ),
            ],
          ),
        ),
      );
    }

    return FadeInTransition(
      child: ShakeTransition(
        trigger: quizState.shakeCounter,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Question Tag
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'QUESTION ${quizState.currentIndex + 1} OF ${quizzes.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Attempts: ${quizState.attempts}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Question Text
              Text(
                quiz.question,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.selectAnswer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),
              // Options List
              ...quiz.options.map((option) {
                final isSelected = quizState.selectedOption == option;
                final isCorrect = quiz.answer.trim().toLowerCase() == option.trim().toLowerCase();
                
                // Color coding based on validation state
                Color optionBgColor = Colors.white.withValues(alpha: 0.5);
                Color optionBorderColor = AppColors.glassCardBorder;
                Color textColor = AppColors.textDark;
                Widget? feedbackIcon;

                if (isSelected) {
                  if (quizState.status == QuizStatus.correctAnswer) {
                    optionBgColor = AppColors.successGreen.withValues(alpha: 0.9);
                    optionBorderColor = AppColors.successGreen;
                    textColor = Colors.white;
                    feedbackIcon = const Icon(Icons.check_circle, color: Colors.white, size: 24);
                  } else if (quizState.status == QuizStatus.wrongAnswer) {
                    optionBgColor = AppColors.errorRed.withValues(alpha: 0.9);
                    optionBorderColor = AppColors.errorRed;
                    textColor = Colors.white;
                    feedbackIcon = const Icon(Icons.cancel, color: Colors.white, size: 24);
                  } else {
                    optionBgColor = AppColors.skyBlue.withValues(alpha: 0.8);
                    optionBorderColor = AppColors.skyBlue;
                    textColor = Colors.white;
                    feedbackIcon = const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    );
                  }
                }

                // If another option was marked correct, highlight it to guide the user
                final showCorrectHighlight = quizState.status == QuizStatus.correctAnswer && isCorrect && !isSelected;
                if (showCorrectHighlight) {
                  optionBgColor = AppColors.successGreen.withValues(alpha: 0.35);
                  optionBorderColor = AppColors.successGreen;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: BubblyButton(
                    onPressed: quizState.status == QuizStatus.answering ||
                            quizState.status == QuizStatus.correctAnswer ||
                            quizState.status == QuizStatus.wrongAnswer
                        ? null // block input during verification
                        : () => ref.read(quizNotifierProvider.notifier).submitAnswer(option),
                    backgroundColor: optionBgColor,
                    borderColor: optionBorderColor,
                    borderRadius: 16.0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        ?feedbackIcon,
                      ],
                    ),
                  ),
                );
              }),
              
              // Helper text feedback on answers
              if (quizState.status == QuizStatus.correctAnswer) ...[
                const SizedBox(height: 12),
                Text(
                  AppStrings.correctTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ] else if (quizState.status == QuizStatus.wrongAnswer) ...[
                const SizedBox(height: 12),
                Text(
                  AppStrings.wrongTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
