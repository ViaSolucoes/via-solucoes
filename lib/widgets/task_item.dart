import 'package:flutter/material.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/theme.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone da tarefa
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ViaColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: ViaColors.primary, size: 26),
            ),

            const SizedBox(width: 14),

            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da tarefa
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 4),

                  // Descrição (opcional)
                  if (task.description != null &&
                      task.description!.trim().isNotEmpty)
                    Text(
                      task.description!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: ViaColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            const Icon(Icons.arrow_forward_ios,
                size: 18, color: ViaColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
