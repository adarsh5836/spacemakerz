import 'package:flutter/material.dart';
import '../../../core/enums/app_enums.dart';

/// Colour-coded status badge. Set [compact] = true for smaller chip inside card headers.
class TaskStatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool compact;

  const TaskStatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical:   compact ? 4  : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Container(
              width: 7, height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (status) {
      case TaskStatus.pending:    return const Color(0xFFF59E0B);
      case TaskStatus.inProgress: return const Color(0xFF3B82F6);
      case TaskStatus.completed:  return const Color(0xFF10B981);
      case TaskStatus.rejected:   return const Color(0xFFEF4444);
    }
  }
}
