import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/screens/contracts/contract_detail_screen.dart';
import 'package:viasolucoes/screens/contracts/create_contract_screen.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/contract_card.dart';

class ClientContractsTab extends StatefulWidget {
  final Client client;

  const ClientContractsTab({super.key, required this.client});

  @override
  State<ClientContractsTab> createState() => _ClientContractsTabState();
}

class _ClientContractsTabState extends State<ClientContractsTab> {
  final ContractService _contractService = ContractService();
  List<Contract> _contracts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _loading = true);
    final data = await _contractService.getByClient(widget.client.id);
    setState(() {
      _contracts = data;
      _loading = false;
    });
  }

  Future<void> _createContract() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateContractScreen(client: widget.client),
      ),
    );
    if (result == true) _loadContracts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _createContract,
        backgroundColor: ViaColors.primary,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contracts.isEmpty
          ? const Center(child: Text('Nenhum contrato encontrado.'))
          : RefreshIndicator(
        onRefresh: _loadContracts,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _contracts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final contract = _contracts[i];
            return ContractCard(
              contract: contract,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ContractDetailScreen(contract: contract),
                  ),
                );
              },
            )
                .animate()
                .fadeIn(delay: (i * 60).ms)
                .slideX(begin: 0.15);
          },
        ),
      ),
    );
  }
}
