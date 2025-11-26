import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/services/supabase/contract_service_supabase.dart';
import 'package:viasolucoes/screens/contracts/edit_contract_screen.dart';

class ContractDetailsTab extends StatefulWidget {
  final Contract contract;

  const ContractDetailsTab({
    super.key,
    required this.contract,
  });

  @override
  State<ContractDetailsTab> createState() => _ContractDetailsTabState();
}

class _ContractDetailsTabState extends State<ContractDetailsTab> {
  final DateFormat _date = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');
  final _contractService = ContractServiceSupabase();

  @override
  Widget build(BuildContext context) {
    final c = widget.contract;
    final statusColor = _statusColor(c.status);
    final statusText = _statusLabel(c.status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      children: [
        _sectionTitle("Informações do Contrato"),

        _card([
          _line("Cliente", c.clientName),
          _line("Status", statusText, color: statusColor),
          _line("Data de Início", _date.format(c.startDate)),
          _line("Data de Fim", _date.format(c.endDate)),
          _line("Progresso", "${c.progressPercentage.toStringAsFixed(0)}%"),
        ]),

        const SizedBox(height: 26),
        _sectionTitle("Descrição"),
        _card([
          Text(
            c.description,
            style: const TextStyle(fontSize: 15),
          ),
        ]),

        const SizedBox(height: 26),

        if (c.hasFile == true && c.fileUrl != null) ...[
          _sectionTitle("Anexo do Contrato"),
          _fileCard(c.fileName ?? "arquivo", c.fileUrl!),
          const SizedBox(height: 26),
        ],

        _sectionTitle("Ações"),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _editContract(context),
                icon: const Icon(Icons.edit),
                label: const Text("Editar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ViaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteContract,
                icon: const Icon(Icons.delete_forever),
                label: const Text("Excluir"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // COMPONENTES
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .expand((w) => [w, const SizedBox(height: 10)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  Widget _line(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 🔵 CARD DO ARQUIVO (Visualizar + Baixar)
  // ---------------------------------------------------------------------------

  Widget _fileCard(String fileName, String url) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 32, color: Colors.blue),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 🔵 Botão visualizar
          IconButton(
            icon: const Icon(Icons.visibility_rounded, color: Colors.blue),
            onPressed: () => _openFile(url),
            tooltip: "Visualizar arquivo",
          ),

          // 🔵 Botão baixar
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.blue),
            onPressed: () => _downloadFile(url),
            tooltip: "Baixar arquivo",
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AÇÕES
  // ---------------------------------------------------------------------------

  void _editContract(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditContractScreen(contract: widget.contract),
      ),
    );
  }

  Future<void> _deleteContract() async {
    final confirm = await _confirmDialog(
      "Excluir contrato",
      "Tem certeza que deseja excluir este contrato?",
    );

    if (!confirm) return;

    await _contractService.delete(widget.contract.id);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<bool> _confirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text("Excluir"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ??
        false;
  }

  // ---------------------------------------------------------------------------
  // ABRIR ARQUIVO (PDF / DOC)
  // ---------------------------------------------------------------------------

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível abrir o arquivo."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // BAIXAR ARQUIVO
  // ---------------------------------------------------------------------------

  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível baixar o arquivo."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // FORMATADORES
  // ---------------------------------------------------------------------------

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.blueAccent;
      case 'overdue':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'overdue':
        return 'Atrasado';
      case 'completed':
        return 'Concluído';
      default:
        return 'Indefinido';
    }
  }
}
