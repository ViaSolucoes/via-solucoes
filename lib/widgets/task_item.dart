import 'package:flutter/material.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/theme.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    this.onDelete,
    this.onEdit
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: task.isCompleted
            ? ViaColors.success.withValues(alpha: 0.1)
            : Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.description != null &&
                    task.description!.trim().isNotEmpty)
                  Text(
                    task.description!,
                    style: TextStyle(
                      color: ViaColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
