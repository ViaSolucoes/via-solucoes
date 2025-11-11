import 'package:flutter/material.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/services/client_service.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/client_card.dart';
import 'package:viasolucoes/widgets/client_search_field.dart';
import 'package:viasolucoes/widgets/client_filter_bar.dart';
import 'create_client_screen.dart';
import 'edit_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientService _clientService = ClientService();
  List<Client> _clients = [];
  String _searchQuery = '';
  bool _showActiveOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    await _clientService.initializeSampleData();
    setState(() {
      _clients = _clientService.getClients();
      _isLoading = false;
    });
  }

  void _navigateToCreate() async {
    final newClient = await Navigator.push<Client>(
      context,
      MaterialPageRoute(builder: (context) => const CreateClientScreen()),
    );
    if (newClient != null) {
      _clientService.addClient(newClient);
      await _loadClients();
      _showSnackBar('Cliente adicionado com sucesso!');
    }
  }

  void _navigateToEdit(Client client) async {
    final updatedClient = await Navigator.push<Client>(
      context,
      MaterialPageRoute(builder: (context) => EditClientScreen(client: client)),
    );
    if (updatedClient != null) {
      _clientService.updateClient(updatedClient);
      await _loadClients();
      _showSnackBar('Cliente atualizado com sucesso!');
    }
  }

  void _deleteClient(String id) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Excluir cliente',
      message: 'Tem certeza que deseja excluir este cliente?',
    );
    if (!confirmed) return;

    setState(() {
      _clientService.deleteClient(id);
    });
    _showSnackBar('Cliente removido com sucesso.');
  }

  /// ✅ Atualizado para o modelo imutável (usa copyWith)
  void _toggleClientStatus(Client client) {
    final updatedClient = client.copyWith(
      isActive: !client.isActive,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _clientService.updateClient(updatedClient);
      _clients = _clientService.getClients();
    });

    _showSnackBar(
      updatedClient.isActive
          ? 'Cliente ativado com sucesso.'
          : 'Cliente desativado com sucesso.',
    );
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content:
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ViaColors.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        backgroundColor: ViaColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Client> get _filteredClients {
    return _clients.where((client) {
      final matchesSearch = client.companyName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesActive = !_showActiveOnly || client.isActive;
      return matchesSearch && matchesActive;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredClients;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clientes'),
            Text(
              'Gerencie suas concessionárias',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ViaColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: ViaColors.primary),
            tooltip: 'Novo Cliente',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadClients,
        color: ViaColors.primary,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              ClientSearchField(
                onChanged: (value) =>
                    setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 16),
              ClientFilterBar(
                showActiveOnly: _showActiveOnly,
                onToggle: (selected) =>
                    setState(() => _showActiveOnly = selected),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                  child: Text(
                    'Nenhum cliente encontrado.',
                    style:
                    TextStyle(color: ViaColors.textSecondary),
                  ),
                )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final client = filtered[index];
                    return ClientCard(
                      client: client,
                      onEdit: () => _navigateToEdit(client),
                      onDelete: () => _deleteClient(client.id),
                      onToggleStatus: () =>
                          _toggleClientStatus(client),
                      onTap: () {
                        // Futuro: tela de detalhes do cliente
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
