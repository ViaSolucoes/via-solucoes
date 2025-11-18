import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/screens/create_contract_screen.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/contract_card.dart';
import 'package:viasolucoes/screens/contract_detail_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final _contractService = ContractService();
  List<Contract> _contracts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);

    final all = await _contractService.getAll();

    // Apenas contratos do cliente
    _contracts = all.where((c) => c.clientId == widget.client.id).toList();

    setState(() => _isLoading = false);
  }

  Future<void> _createContract() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateContractScreen(
          client: widget.client, // ← Corrigido
        ),
      ),
    );

    if (result != null) {
      await _loadContracts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.companyName),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ViaColors.primary,
        onPressed: _createContract,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // INFORMAÇÕES DO CLIENTE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ViaColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.companyName,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),

                // 🔥 CAMPO CORRIGIDO
                Text(
                  client.contactPerson,
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 4),
                Text(
                  client.phone,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  client.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 30),
          Text("Contratos", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_contracts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 64, color: ViaColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    "Nenhum contrato encontrado",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: ViaColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ..._contracts.asMap().entries.map(
                  (entry) {
                final index = entry.key;
                final contract = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ContractCard(
                    contract: contract,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContractDetailScreen(contractId: contract.id),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (index * 60).ms)
                      .slideX(begin: 0.15),
                );
              },
            ),
        ],
      ),
    );
  }
}
