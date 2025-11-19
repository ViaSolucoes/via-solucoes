import 'package:flutter/material.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/theme.dart';

class ContractDetailsTab extends StatelessWidget {
  final Contract contract;

  const ContractDetailsTab({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          contract.description,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),

        Text(
          "Responsável: ${contract.assignedUserId}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),

        Text(
          "Período: "
              "${contract.startDate.day}/${contract.startDate.month}/${contract.startDate.year} "
              "até "
              "${contract.endDate.day}/${contract.endDate.month}/${contract.endDate.year}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        if (contract.hasFile)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ViaColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contract.fileName ?? "arquivo",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
