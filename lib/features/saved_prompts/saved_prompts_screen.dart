import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/utils/extensions.dart';
import 'package:agent_prompt/core/utils/snackbar_utils.dart';
import 'package:agent_prompt/core/widgets/gradient_background.dart';
import 'package:agent_prompt/core/widgets/shimmer_loading.dart';
import 'package:agent_prompt/core/widgets/empty_state_widget.dart';
import 'package:agent_prompt/models/prompt_model.dart';
import 'package:agent_prompt/providers/prompt_provider.dart';
import 'package:agent_prompt/providers/auth_provider.dart';

class SavedPromptsScreen extends ConsumerStatefulWidget {
  const SavedPromptsScreen({super.key});

  @override
  ConsumerState<SavedPromptsScreen> createState() => _SavedPromptsScreenState();
}

class _SavedPromptsScreenState extends ConsumerState<SavedPromptsScreen> {
  final _searchCtrl = TextEditingController();
  bool _isSearchOpen = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedPromptsNotifierProvider.notifier).loadPrompts(reset: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(savedPromptsNotifierProvider.notifier).loadPrompts();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedPromptsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _isSearchOpen
                          ? TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Search prompts...',
                                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                              ),
                              onChanged: (q) => ref.read(savedPromptsNotifierProvider.notifier).search(q),
                            ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.3)
                          : Text(
                              'Saved Prompts',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearchOpen = !_isSearchOpen;
                          if (!_isSearchOpen) {
                            _searchCtrl.clear();
                            ref.read(savedPromptsNotifierProvider.notifier).loadPrompts(reset: true);
                          }
                        });
                      },
                      icon: Icon(_isSearchOpen ? Icons.close_rounded : Icons.search_rounded),
                    ),
                  ],
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    _FilterChip(label: 'All', isSelected: state.filter == 'all', onTap: () => ref.read(savedPromptsNotifierProvider.notifier).setFilter('all')),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Favorites', isSelected: state.filter == 'favorites', onTap: () => ref.read(savedPromptsNotifierProvider.notifier).setFilter('favorites'), icon: Icons.favorite_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // List
              Expanded(
                child: state.isLoading && state.prompts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: ShimmerList(itemCount: 6),
                      )
                    : state.prompts.isEmpty
                        ? NoPromptsWidget(
                            onCreatePrompt: () => context.push('/prompt-wizard'),
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: state.prompts.length + (state.isLoading ? 1 : 0),
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              if (index == state.prompts.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final prompt = state.prompts[index];
                              return Dismissible(
                                key: Key(prompt.promptId),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                                ),
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Delete Prompt?'),
                                      content: const Text('This action cannot be undone.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(c, true),
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (_) {
                                  ref.read(savedPromptsNotifierProvider.notifier).deletePrompt(prompt.promptId);
                                  SnackbarUtils.showInfo(context, 'Prompt deleted');
                                },
                                child: _PromptCard(
                                  prompt: prompt,
                                  onTap: () => context.push('/prompt-detail/${prompt.promptId}'),
                                  onFavorite: () => ref.read(savedPromptsNotifierProvider.notifier).toggleFavorite(prompt.promptId),
                                  onCopy: () async {
                                    await Clipboard.setData(ClipboardData(text: prompt.content));
                                    if (context.mounted) SnackbarUtils.showSuccess(context, 'Copied!');
                                  },
                                  onShare: () => Share.share(prompt.content, subject: prompt.title),
                                ),
                              ).animate(delay: (index * 40).ms).fadeIn().slideY(begin: 0.1);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: isSelected ? Colors.white : AppColors.darkTextTertiary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final PromptModel prompt;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _PromptCard({
    required this.prompt,
    required this.onTap,
    required this.onFavorite,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    prompt.projectType,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
                const Spacer(),
                Text(
                  prompt.createdAt.timeAgo,
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    prompt.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 18,
                    color: prompt.isFavorite ? AppColors.accent : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              prompt.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              prompt.preview,
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniAction(icon: Icons.copy_rounded, label: 'Copy', onTap: onCopy),
                const SizedBox(width: 8),
                _MiniAction(icon: Icons.share_rounded, label: 'Share', onTap: onShare),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
        ],
      ),
    );
  }
}
