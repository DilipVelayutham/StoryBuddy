import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/animations/fade_in_transition.dart';
import '../../../../shared/widgets/bubbly_button.dart';
import '../providers/story_provider.dart';
import 'glass_card.dart';

class StoryContent extends ConsumerWidget {
  const StoryContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyState = ref.watch(storyBuddyNotifierProvider);
    final story = storyState.story;

    if (story == null) {
      if (storyState.status == StoryStatus.loading) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryPurple,
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return FadeInTransition(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Narrative Header
            Row(
              children: [
                const Text(
                  '📖',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 8),
                Text(
                  'Our Adventure Story',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryDeepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Story Text
            Text(
              story.storyText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // Status and Buttons
            _buildNarrationControls(context, ref, storyState),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrationControls(
    BuildContext context,
    WidgetRef ref,
    StoryBuddyState state,
  ) {
    final status = state.status;
    final notifier = ref.read(storyBuddyNotifierProvider.notifier);

    switch (status) {
      case StoryStatus.loading:
        return Column(
          children: [
            const LinearProgressIndicator(
              color: AppColors.primaryPurple,
              backgroundColor: AppColors.lavender,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.ttsPreparing,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        );
        
      case StoryStatus.playing:
        return Column(
          children: [
            Text(
              AppStrings.ttsPlaying,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            BubblyButton.text(
              onPressed: () => notifier.stopReading(),
              label: 'Stop Narration 🛑',
              backgroundColor: AppColors.coralOrange,
            ),
          ],
        );

      case StoryStatus.completed:
        return Text(
          AppStrings.ttsFinished,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.successGreen,
                fontWeight: FontWeight.bold,
              ),
        );

      case StoryStatus.error:
        return Column(
          children: [
            Text(
              '${AppStrings.ttsError}\n(${state.errorMessage})',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.errorRed,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 12),
            BubblyButton.text(
              onPressed: () => notifier.startReading(),
              label: 'Retry voice 🎙️',
              backgroundColor: AppColors.skyBlue,
            ),
          ],
        );

      case StoryStatus.initial:
      default:
        return Center(
          child: BubblyButton.text(
            onPressed: () => notifier.startReading(),
            label: AppStrings.readMeStory,
            backgroundColor: AppColors.primaryPurple,
            icon: Icons.volume_up_rounded,
          ),
        );
    }
  }
}
