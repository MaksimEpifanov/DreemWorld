import 'package:flutter/material.dart';

import '../../../core/theme/index.dart';
import '../../../data/models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color backgroundColor = isMine
        ? scheme.primary.withValues(alpha: 0.9)
        : scheme.surfaceContainerHighest;
    final Color textColor = isMine ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadius.mdAll.copyWith(
            bottomRight: isMine ? const Radius.circular(AppRadius.sm) : const Radius.circular(AppRadius.lg),
            bottomLeft: isMine ? const Radius.circular(AppRadius.lg) : const Radius.circular(AppRadius.sm),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message.displayText,
              style: AppTextStyles.body().copyWith(color: textColor),
            ),
            if (message.createdAt != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatTime(message.createdAt!),
                style: AppTextStyles.caption().copyWith(
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

