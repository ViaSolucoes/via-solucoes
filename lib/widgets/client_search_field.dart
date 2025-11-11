import 'package:flutter/material.dart';
import 'package:viasolucoes/theme.dart';

class ClientSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ClientSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar cliente...',
        prefixIcon: const Icon(Icons.search, color: ViaColors.textSecondary),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
