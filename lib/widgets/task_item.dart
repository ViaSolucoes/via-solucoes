import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viaflow/models/task.dart';
import 'package:viaflow/theme.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'urgent':
        return ViaColors.error;
      case 'high':
        return ViaColors.accent;
      case 'medium':
        return ViaColors.secondary;
      case 'low':
        return ViaColors.textSecondary;
      default:
        return ViaColors.textSecondary;
    }
  }

  Color _getStatusColor() {
    switch (task.status) {
      case 'completed':
        return ViaColors.success;
      case 'in_progress':
        return ViaColors.secondary;
      case 'overdue':
        return ViaColors.error;
      case 'pending':
        return ViaColors.accent;
      default:
        return ViaColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    switch (task.status) {
      case 'completed':
        return 'Concluído';
      case 'in_progress':
        return 'Em andamento';
      case 'overdue':
        return 'Atrasado';
      case 'pending':
        return 'Pendente';
      default:
        return task.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getPriorityColor().withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ViaColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 14,
                color: ViaColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(task.dueDate),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getPriorityColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                task.priority.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getPriorityColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
