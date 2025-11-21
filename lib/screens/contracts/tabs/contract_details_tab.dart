import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/theme.dart';

class ContractDetailsTab extends StatelessWidget {
  final Contract contract;

  ContractDetailsTab({super.key, required this.contract});

  final _formatter = DateFormat("d 'de' MMMM 'de' yyyy", "pt_BR");

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        _infoSection(
          title: "Informações Gerais",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contract.description,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _textLine("Responsável", contract.assignedUserId ?? "Não informado"),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _infoSection(
          title: "Período",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textLine(
                "Início",
                _formatter.format(contract.startDate),
              ),
              const SizedBox(height: 6),
              _textLine(
                "Término",
                _formatter.format(contract.endDate),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _infoSection(
          title: "Status",
          child: _statusBadge(contract.status),
        ),

        const SizedBox(height: 20),

        if (contract.hasFile) _fileSection(contract),
      ],
    );
  }

  // -----------------------------------------------------------------------------------
  // COMPONENTES
  // -----------------------------------------------------------------------------------

  Widget _infoSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _textLine(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _fileSection(Contract c) {
    return _infoSection(
      title: "Arquivo Anexado",
      child: Row(
        children: [
          const Icon(Icons.attach_file, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              c.fileName ?? "arquivo",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    late final Color color;
    late final String label;

    switch (status) {
      case "active":
        color = Colors.blueAccent;
        label = "Ativo";
        break;
      case "overdue":
        color = Colors.orangeAccent;
        label = "Atrasado";
        break;
      case "completed":
        color = Colors.green;
        label = "Concluído";
        break;
      default:
        color = Colors.grey;
        label = "Indefinido";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
