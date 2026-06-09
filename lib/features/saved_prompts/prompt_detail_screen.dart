import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/utils/extensions.dart';
import 'package:agent_prompt/core/utils/snackbar_utils.dart';
import 'package:agent_prompt/core/widgets/shimmer_loading.dart';
import 'package:agent_prompt/core/widgets/empty_state_widget.dart';
import 'package:agent_prompt/providers/prompt_provider.dart';
import 'package:agent_prompt/providers/user_provider.dart';
import 'package:agent_prompt/services/firestore_service.dart';

class PromptDetailScreen extends ConsumerWidget {
  final String promptId;

  const PromptDetailScreen({super.key, required this.promptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptAsync = ref.watch(promptDetailProvider(promptId));

    return Scaffold(
      backgroundColor: AppColors.terminalBg,
      body: SafeArea(
        child: promptAsync.when(
          data: (prompt) {
            if (prompt == null) {
              return EmptyStateWidget(
                icon: Icons.description_outlined,
                title: 'Prompt Not Found',
                description: 'This prompt may have been deleted.',
                actionText: 'Go Back',
                onAction: () => context.pop(),
              );
            }
            return Column(
              children: [
                // Terminal header
                Container(
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D2D2D),
                    border: Border(bottom: BorderSide(color: Color(0xFF3D3D3D))),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.terminalDotRed, shape: BoxShape.circle)),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.terminalDotYellow, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.terminalDotGreen, shape: BoxShape.circle)),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          prompt.title,
                          style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, color: Color(0xFF999999), size: 20),
                        color: const Color(0xFF2D2D2D),
                        onSelected: (value) async {
                          switch (value) {
                            case 'copy':
                              await Clipboard.setData(ClipboardData(text: prompt.content));
                              if (context.mounted) SnackbarUtils.showSuccess(context, 'Copied!');
                              break;
                            case 'share':
                              await Share.share(prompt.content, subject: prompt.title);
                              break;
                            case 'favorite':
                              await ref.read(firestoreServiceProvider).toggleFavorite(promptId, !prompt.isFavorite);
                              ref.invalidate(promptDetailProvider(promptId));
                              break;
                            case 'delete':
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Prompt?'),
                                  content: const Text('This cannot be undone.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                    ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                await ref.read(firestoreServiceProvider).deletePrompt(promptId);
                                context.pop();
                              }
                              break;
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'copy', child: Row(children: [Icon(Icons.copy_rounded, color: Colors.white, size: 18), SizedBox(width: 10), Text('Copy', style: TextStyle(color: Colors.white))])),
                          const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share_rounded, color: Colors.white, size: 18), SizedBox(width: 10), Text('Share', style: TextStyle(color: Colors.white))])),
                          PopupMenuItem(value: 'favorite', child: Row(children: [Icon(prompt.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.accent, size: 18), const SizedBox(width: 10), Text(prompt.isFavorite ? 'Unfavorite' : 'Favorite', style: const TextStyle(color: Colors.white))])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, color: AppColors.error, size: 18), SizedBox(width: 10), Text('Delete', style: TextStyle(color: AppColors.error))])),
                        ],
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),

                // Prompt info bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF252526),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                        child: Text(prompt.projectType, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      Text(prompt.createdAt.formattedDate, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                      if (prompt.isFavorite) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.favorite_rounded, size: 13, color: AppColors.accent),
                      ],
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      prompt.content,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: AppColors.terminalText,
                        height: 1.7,
                      ),
                    ),
                  ),
                ),

                // Bottom action bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF252526),
                    border: Border(top: BorderSide(color: Color(0xFF3D3D3D))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TerminalAction(
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: prompt.content));
                          if (context.mounted) SnackbarUtils.showSuccess(context, 'Copied!');
                        },
                      ),
                      _TerminalAction(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: () => Share.share(prompt.content, subject: prompt.title),
                      ),
                      _TerminalAction(
                        icon: prompt.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        label: 'Favorite',
                        color: prompt.isFavorite ? AppColors.accent : null,
                        onTap: () async {
                          await ref.read(firestoreServiceProvider).toggleFavorite(promptId, !prompt.isFavorite);
                          ref.invalidate(promptDetailProvider(promptId));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(padding: EdgeInsets.all(20), child: ShimmerCard(height: 400)),
          error: (_, __) => EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Error Loading Prompt',
            description: 'Please try again later.',
            actionText: 'Go Back',
            onAction: () => context.pop(),
          ),
        ),
      ),
    );
  }
}

class _TerminalAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _TerminalAction({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFCCCCCC);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
