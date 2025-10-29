import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viaflow/models/contract.dart';
import 'package:viaflow/theme.dart';

class RecentContractItem extends StatelessWidget {
  final Contract contract;

  const RecentContractItem({super.key, required this.contract});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.clientName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(contract.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ViaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${contract.progressPercentage.toInt()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
