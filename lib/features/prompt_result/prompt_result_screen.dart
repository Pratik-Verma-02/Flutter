import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/constants/app_constants.dart';
import 'package:agent_prompt/core/utils/snackbar_utils.dart';
import 'package:agent_prompt/core/widgets/shimmer_loading.dart';
import 'package:agent_prompt/providers/prompt_provider.dart';
import 'package:agent_prompt/providers/user_provider.dart';
import 'package:agent_prompt/services/firestore_service.dart';
import 'package:agent_prompt/features/prompt_result/edit_prompt_sheet.dart';
import 'package:agent_prompt/features/prompt_result/add_requirements_sheet.dart';

class PromptResultScreen extends ConsumerStatefulWidget {
  final String promptId;
  final String? initialContent;

  const PromptResultScreen({super.key, required this.promptId, this.initialContent});

  @override
  ConsumerState<PromptResultScreen> createState() => _PromptResultScreenState();
}

class _PromptResultScreenState extends ConsumerState<PromptResultScreen> {
  String _displayedText = '';
  bool _isTyping = false;
  bool _isSaved = true;
  Timer? _typewriterTimer;
  final ScrollController _scrollController = ScrollController();
  String _currentContent = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialContent != null) {
      _currentContent = widget.initialContent!;
      _startTypewriter(_currentContent);
    }
  }

  void _startTypewriter(String text) {
    _typewriterTimer?.cancel();
    setState(() {
      _displayedText = '';
      _isTyping = true;
    });

    // Show text in chunks for better performance
    const chunkSize = 5;
    int index = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 8), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index >= text.length) {
        timer.cancel();
        setState(() => _isTyping = false);
        return;
      }
      setState(() {
        _displayedText = text.substring(0, (index + chunkSize).clamp(0, text.length));
        index += chunkSize;
      });
      // Auto-scroll
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    final content = _currentContent.isNotEmpty ? _currentContent : widget.initialContent ?? '';
    await Clipboard.setData(ClipboardData(text: content));
    if (mounted) SnackbarUtils.showSuccess(context, 'Prompt copied to clipboard!');
  }

  Future<void> _share() async {
    final content = _currentContent.isNotEmpty ? _currentContent : widget.initialContent ?? '';
    await Share.share(content, subject: 'AgentPrompt: Development Prompt');
  }

  Future<void> _openEditSheet() async {
    final credits = ref.read(creditsProvider).valueOrNull ?? 0;
    if (credits < AppConstants.editCost) {
      SnackbarUtils.showError(context, 'Insufficient credits. You need ${AppConstants.editCost} credits to edit.');
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditPromptSheet(
        promptId: widget.promptId,
        currentContent: _currentContent.isNotEmpty ? _currentContent : widget.initialContent ?? '',
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentContent = result;
        _isSaved = false;
      });
      _startTypewriter(result);
    }
  }

  Future<void> _openAddSheet() async {
    final credits = ref.read(creditsProvider).valueOrNull ?? 0;
    if (credits < AppConstants.addRequirementsCost) {
      SnackbarUtils.showError(context, 'Insufficient credits. You need ${AppConstants.addRequirementsCost} credits.');
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddRequirementsSheet(
        promptId: widget.promptId,
        currentContent: _currentContent.isNotEmpty ? _currentContent : widget.initialContent ?? '',
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentContent = result;
        _isSaved = false;
      });
      _startTypewriter(result);
    }
  }

  Future<void> _save() async {
    if (_isSaved) return;
    try {
      await ref.read(firestoreServiceProvider).updatePrompt(widget.promptId, {
        'content': _currentContent,
      });
      if (mounted) {
        setState(() => _isSaved = true);
        SnackbarUtils.showSuccess(context, 'Prompt saved!');
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Failed to save prompt.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _displayedText.isNotEmpty ? _displayedText : (widget.initialContent ?? '');

    return Scaffold(
      backgroundColor: AppColors.terminalBg,
      body: SafeArea(
        child: Column(
          children: [
            // Terminal header
            _TerminalHeader(
              onBack: () => context.pop(),
            ).animate().fadeIn(duration: 300.ms),

            // Terminal body
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prompt text with cursor
                    Text(
                      content + (_isTyping ? '▋' : ''),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: AppColors.terminalText,
                        height: 1.7,
                      ),
                    ),
                    if (!_isTyping && content.isEmpty)
                      const ShimmerCard(height: 300),
                  ],
                ),
              ),
            ),

            // Action bar
            _ActionBar(
              isTyping: _isTyping,
              isSaved: _isSaved,
              onCopy: _copy,
              onShare: _share,
              onEdit: _openEditSheet,
              onAdd: _openAddSheet,
              onSave: _save,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }
}

class _TerminalHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _TerminalHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        border: Border(bottom: BorderSide(color: Color(0xFF3D3D3D))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // Traffic lights
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(color: AppColors.terminalDotRed, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.terminalDotYellow, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.terminalDotGreen, shape: BoxShape.circle)),
          const Spacer(),
          const Text(
            'AgentPrompt Terminal',
            style: TextStyle(color: Color(0xFF999999), fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const SizedBox(width: 60),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool isTyping;
  final bool isSaved;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final VoidCallback onSave;

  const _ActionBar({
    required this.isTyping,
    required this.isSaved,
    required this.onCopy,
    required this.onShare,
    required this.onEdit,
    required this.onAdd,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF252526),
        border: Border(top: BorderSide(color: Color(0xFF3D3D3D))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(icon: Icons.copy_rounded, label: 'Copy', onTap: onCopy, enabled: !isTyping),
          _ActionBtn(icon: Icons.share_rounded, label: 'Share', onTap: onShare, enabled: !isTyping),
          _ActionBtn(icon: Icons.edit_rounded, label: 'Edit', onTap: onEdit, enabled: !isTyping, creditCost: AppConstants.editCost),
          _ActionBtn(icon: Icons.add_rounded, label: 'Add Req', onTap: onAdd, enabled: !isTyping, creditCost: AppConstants.addRequirementsCost),
          _ActionBtn(
            icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            label: isSaved ? 'Saved' : 'Save',
            onTap: onSave,
            enabled: !isTyping,
            color: isSaved ? AppColors.terminalGreen : null,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final int? creditCost;
  final Color? color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.creditCost,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (enabled ? const Color(0xFFCCCCCC) : const Color(0xFF666666));
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: c, size: 22),
                if (creditCost != null)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(6)),
                      child: Text('$creditCost', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.black)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
