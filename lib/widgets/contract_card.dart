import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viaflow/models/contract.dart';
import 'package:viaflow/theme.dart';

class ContractCard extends StatelessWidget {
  final Contract contract;
  final VoidCallback onTap;

  const ContractCard({super.key, required this.contract, required this.onTap});

  Color _getStatusColor() {
    switch (contract.status) {
      case 'active':
        return ViaColors.secondary;
      case 'overdue':
        return ViaColors.error;
      case 'completed':
        return ViaColors.success;
      default:
        return ViaColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    switch (contract.status) {
      case 'active':
        return 'Ativo';
      case 'overdue':
        return 'Atrasado';
      case 'completed':
        return 'Concluído';
      default:
        return contract.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor().withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    contract.clientName,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              contract.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ViaColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: ViaColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(contract.endDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${contract.progressPercentage.toInt()}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: contract.progressPercentage / 100,
                minHeight: 6,
                backgroundColor: ViaColors.textSecondary.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(_getStatusColor()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
