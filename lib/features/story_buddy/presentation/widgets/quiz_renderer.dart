import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/shake_transition.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/animations/fade_in_transition.dart';
import '../../../../shared/widgets/bubbly_button.dart';
import '../providers/quiz_provider.dart';
import '../providers/story_provider.dart';
import '../providers/pip_provider.dart';
import 'glass_card.dart';

class QuizRenderer extends ConsumerWidget {
  const QuizRenderer({super.key});

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
      return FadeInTransition(
        child: GlassCard(
          borderColor: AppColors.successGreen.withOpacity(0.5),
          color: AppColors.successGreen.withOpacity(0.1),
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
                  ref.read(quizNotifierProvider.notifier).reset();
                  ref.read(quizNotifierProvider.notifier).revealQuiz();
                  ref.read(pipStateProvider.notifier).updateState(PipState.listening);
                },
                label: 'Retake Quiz 🔄',
                backgroundColor: AppColors.primaryPurple,
                icon: Icons.replay,
              ),
              const SizedBox(height: 12),
              BubblyButton.text(
                onPressed: () {
                  ref.read(storyBuddyNotifierProvider.notifier).reset();
                },
                label: 'Start Adventure Over 📖',
                backgroundColor: AppColors.skyBlue,
                icon: Icons.home,
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
                Color optionBgColor = Colors.white.withOpacity(0.5);
                Color optionBorderColor = AppColors.glassCardBorder;
                Color textColor = AppColors.textDark;
                Widget? feedbackIcon;

                if (isSelected) {
                  if (quizState.status == QuizStatus.correctAnswer) {
                    optionBgColor = AppColors.successGreen.withOpacity(0.9);
                    optionBorderColor = AppColors.successGreen;
                    textColor = Colors.white;
                    feedbackIcon = const Icon(Icons.check_circle, color: Colors.white, size: 24);
                  } else if (quizState.status == QuizStatus.wrongAnswer) {
                    optionBgColor = AppColors.errorRed.withOpacity(0.9);
                    optionBorderColor = AppColors.errorRed;
                    textColor = Colors.white;
                    feedbackIcon = const Icon(Icons.cancel, color: Colors.white, size: 24);
                  } else {
                    optionBgColor = AppColors.skyBlue.withOpacity(0.8);
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
                  optionBgColor = AppColors.successGreen.withOpacity(0.35);
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
                        if (feedbackIcon != null) feedbackIcon,
                      ],
                    ),
                  ),
                );
              }).toList(),
              
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
