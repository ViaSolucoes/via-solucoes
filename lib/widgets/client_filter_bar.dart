import 'package:flutter/material.dart';
import 'package:viasolucoes/theme.dart';

class ClientFilterBar extends StatelessWidget {
  final bool showActiveOnly;
  final ValueChanged<bool> onToggle;

  const ClientFilterBar({
    super.key,
    required this.showActiveOnly,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FilterChip(
          label: Text(
            'Ativos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: showActiveOnly
                  ? ViaColors.primary
                  : ViaColors.textSecondary,
              fontWeight:
              showActiveOnly ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: showActiveOnly,
          onSelected: onToggle,
          selectedColor: ViaColors.primary.withOpacity(0.12),
          backgroundColor: theme.cardColor,
          checkmarkColor: ViaColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: showActiveOnly
                  ? ViaColors.primary.withOpacity(0.6)
                  : ViaColors.textSecondary.withOpacity(0.2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: Text(
            'Todos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: !showActiveOnly
                  ? ViaColors.primary
                  : ViaColors.textSecondary,
              fontWeight:
              !showActiveOnly ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: !showActiveOnly,
          onSelected: (_) => onToggle(false),
          selectedColor: ViaColors.primary.withOpacity(0.12),
          backgroundColor: theme.cardColor,
          checkmarkColor: ViaColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: !showActiveOnly
                  ? ViaColors.primary.withOpacity(0.6)
                  : ViaColors.textSecondary.withOpacity(0.2),
            ),
          ),
        ),
      ],
    );
  }
}
