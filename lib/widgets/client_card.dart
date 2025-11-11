import 'package:flutter/material.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/theme.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus; // novo callback

  const ClientCard({
    super.key,
    required this.client,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus, // novo parâmetro
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Text(
                client.highway,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: ViaColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: ViaColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${client.contactPerson} (${client.contactRole})',
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email_outlined,
                      color: ViaColors.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      client.email,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.phone_outlined,
                      color: ViaColors.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text(client.phone, style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Atualizado em ${client.updatedAt.day}/${client.updatedAt.month}/${client.updatedAt.year}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: ViaColors.textSecondary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: ViaColors.secondary,
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: ViaColors.error,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isActive = client.isActive;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            client.companyName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: ViaColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            // Toggle switch moderno
            Switch.adaptive(
              value: isActive,
              activeColor: ViaColors.success,
              inactiveThumbColor: ViaColors.error,
              onChanged: (_) => onToggleStatus?.call(),
            ),
          ],
        ),
      ],
    );
  }
}
