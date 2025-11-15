import 'package:flutter/material.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/theme.dart';

class ClientDetailScreen extends StatelessWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          client.companyName,
          style: theme.textTheme.titleLarge,
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // abrir edição futuramente
            },
            icon: const Icon(Icons.edit, color: ViaColors.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Informações Gerais", theme),
            _buildInfoCard(
              [
                _infoRow(Icons.location_city, "Rodovia", client.highway),
                _infoRow(Icons.business, "CNPJ", client.cnpj),
                _infoRow(Icons.person, "Responsável",
                    "${client.contactPerson} (${client.contactRole})"),
                _infoRow(Icons.email, "E-mail", client.email),
                _infoRow(Icons.phone, "Telefone", client.phone),
                _infoRow(Icons.location_on, "Endereço", client.address),
                _infoRow(Icons.note_alt, "Observações",
                    client.notes.isEmpty ? "Nenhuma" : client.notes),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle("Status", theme),
            _buildStatusCard(client, theme),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Contratos Vinculados", theme),
                TextButton.icon(
                  onPressed: () {
                    // abrir criação de contrato
                  },
                  icon: const Icon(Icons.add, color: ViaColors.primary),
                  label: const Text("Novo Contrato"),
                ),
              ],
            ),

            _buildContractsList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ------- COMPONENTES ----------

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: ViaColors.primary,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: ViaColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, color: ViaColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16,
                        color: ViaColors.textPrimary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Client client, ThemeData theme) {
    final bool active = client.isActive;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              active ? Icons.check_circle : Icons.cancel,
              color: active ? ViaColors.success : ViaColors.error,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                active ? "Cliente Ativo" : "Cliente Inativo",
                style: theme.textTheme.titleMedium?.copyWith(
                    color: active ? ViaColors.success : ViaColors.error),
              ),
            ),
            Switch(
              value: active,
              activeColor: ViaColors.success,
              onChanged: (_) {
                // 👉 Integraremos com toggle futuramente
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContractsList() {
    final mockContracts = [
      {"title": "Contrato de Manutenção 2024", "status": "Ativo"},
      {"title": "Contrato de Monitoramento 2023", "status": "Encerrado"},
    ];

    return Column(
      children: mockContracts.map((c) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(c["title"]!,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: Text(
              c["status"]!,
              style: TextStyle(
                color: c["status"] == "Ativo"
                    ? ViaColors.success
                    : ViaColors.textSecondary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // abrir detalhes do contrato futuramente
            },
          ),
        );
      }).toList(),
    );
  }
}
