import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/screens/contracts/contract_detail_screen.dart';
import 'package:viasolucoes/screens/contracts/edit_contract_screen.dart';
import 'package:viasolucoes/screens/contracts/create_contract_screen.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/theme.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final _contractService = ContractService();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  List<Contract> _contracts = [];
  bool _loadingContracts = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _loadingContracts = true);
    final data = await _contractService.getByClient(widget.client.id);
    setState(() {
      _contracts = data;
      _loadingContracts = false;
    });
  }

  Future<void> _createContract() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateContractScreen(client: widget.client),
      ),
    );

    if (result == true) {
      _loadContracts();
    }
  }

  Future<void> _editContract(Contract contract) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditContractScreen(contract: contract),
      ),
    );

    if (result == true) {
      _loadContracts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.companyName),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createContract,
        backgroundColor: ViaColors.primary,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadContracts,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // =============== CARD PRINCIPAL DO CLIENTE ==================
            _buildClientCard(client),

            const SizedBox(height: 24),

            // =============== CABEÇALHO DE CONTRATOS =====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contratos deste cliente',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: _loadContracts,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar contratos',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // =============== LISTA DE CONTRATOS =========================
            if (_loadingContracts)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_contracts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 56, color: ViaColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum contrato cadastrado para este cliente.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ViaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _contracts
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildContractItem(entry.value)
                      .animate()
                      .fadeIn(delay: (entry.key * 80).ms)
                      .slideY(begin: 0.1),
                )
                    .toList(),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD DO CLIENTE
  // ---------------------------------------------------------------------------
  Widget _buildClientCard(Client client) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            client.companyName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          if (client.highway != null && client.highway!.isNotEmpty)
            Text(
              client.highway!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ViaColors.textSecondary,
              ),
            ),
          const SizedBox(height: 8),
          if (client.cnpj != null && client.cnpj!.isNotEmpty)
            Text(
              'CNPJ: ${client.cnpj}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ViaColors.textSecondary,
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  client.contactPerson ?? 'Contato não informado',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  client.phone ?? 'Telefone não informado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ViaColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  client.email ?? 'E-mail não informado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ViaColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ITEM DE CONTRATO
  // ---------------------------------------------------------------------------
  Widget _buildContractItem(Contract contract) {
    final endDate =
    contract.endDate != null ? _dateFormat.format(contract.endDate) : '-';

    Color statusColor;
    String statusLabel;

    switch (contract.status) {
      case 'completed':
        statusColor = Colors.green;
        statusLabel = 'Concluído';
        break;
      case 'overdue':
        statusColor = Colors.red;
        statusLabel = 'Atrasado';
        break;
      default:
        statusColor = ViaColors.primary;
        statusLabel = 'Ativo';
    }

    final progress = contract.progressPercentage.clamp(0, 100);

    return GestureDetector(
      onTap: () {
        // abre detalhes completos do contrato
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContractDetailScreen(contract: contract),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // título + status + botão editar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    contract.description.isNotEmpty
                        ? contract.description
                        : 'Contrato sem descrição',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _editContract(contract),
                  tooltip: 'Editar contrato',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Término em $endDate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ViaColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // barra de progresso
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                AlwaysStoppedAnimation<Color>(ViaColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${progress.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ViaColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
