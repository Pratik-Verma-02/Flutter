import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/constants/app_constants.dart';
import 'package:agent_prompt/core/utils/snackbar_utils.dart';
import 'package:agent_prompt/providers/api_service_provider.dart';
import 'package:agent_prompt/providers/user_provider.dart';
import 'package:agent_prompt/services/firestore_service.dart';

class EditPromptSheet extends ConsumerStatefulWidget {
  final String promptId;
  final String currentContent;

  const EditPromptSheet({super.key, required this.promptId, required this.currentContent});

  @override
  ConsumerState<EditPromptSheet> createState() => _EditPromptSheetState();
}

class _EditPromptSheetState extends ConsumerState<EditPromptSheet> {
  final _ctrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (_ctrl.text.trim().isEmpty) {
      SnackbarUtils.showError(context, 'Please describe your modifications');
      return;
    }

    final credits = ref.read(creditsProvider).valueOrNull ?? 0;
    if (credits < AppConstants.editCost) {
      SnackbarUtils.showError(context, 'Insufficient credits.');
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.editPrompt(widget.promptId, _ctrl.text.trim());
      final newContent = result['content'] as String? ?? widget.currentContent;

      await ref.read(firestoreServiceProvider).updatePrompt(widget.promptId, {'content': newContent});

      if (mounted) Navigator.pop(context, newContent);
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Failed to edit prompt. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  const Text('Edit Prompt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(children: [
                      Icon(Icons.bolt_rounded, color: AppColors.warning, size: 14),
                      SizedBox(width: 4),
                      Text('2 credits', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Describe what changes you want to make to the prompt',
                style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ctrl,
                        maxLines: null,
                        expands: true,
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'e.g., Make the architecture section more detailed, add microservices pattern...',
                          hintStyle: TextStyle(color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _apply,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Apply Changes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
