import 'package:flutter/material.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/services/supabase/client_service_supabase.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/client_card.dart';
import 'package:viasolucoes/widgets/client_search_field.dart';
import 'package:viasolucoes/widgets/client_filter_bar.dart';

import 'create_client_screen.dart';
import 'edit_client_screen.dart';
import 'client_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientServiceSupabase _clientService = ClientServiceSupabase();

  List<Client> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  // ============================================================
  // 🔵 BUSCAR CLIENTES
  // ============================================================
  Future<void> _loadClients() async {
    setState(() => _isLoading = true);

    try {
      final data = await _clientService.getAll();
      setState(() => _clients = data);
    } catch (e) {
      print("❌ Erro ao carregar clientes: $e");
    }

    setState(() => _isLoading = false);
  }

  // ============================================================
  // 🔵 CRIAR CLIENTE
  // ============================================================
  void _navigateToCreate() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateClientScreen()),
    );

    if (created == true) {
      _loadClients();
      _showSnackBar("Cliente criado com sucesso!");
    }
  }

  // ============================================================
  // 🔵 EDITAR CLIENTE
  // ============================================================
  void _navigateToEdit(Client client) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditClientScreen(client: client)),
    );

    if (updated == true) {
      _loadClients();
      _showSnackBar("Cliente atualizado com sucesso!");
    }
  }

  // ============================================================
  // 🔵 DELETAR CLIENTE
  // ============================================================
  Future<void> _deleteClient(String id) async {
    final confirm = await _showConfirmationDialog(
      title: "Excluir cliente",
      message: "Tem certeza que deseja excluir este cliente?",
    );

    if (!confirm) return;

    try {
      await _clientService.delete(id);
      _loadClients();
      _showSnackBar("Cliente excluído com sucesso!");
    } catch (e) {
      print("❌ Erro ao excluir cliente: $e");
    }
  }

  // ============================================================
  // 🔵 ALTERAR STATUS (ATIVAR/DESATIVAR)
  // ============================================================
  Future<void> _toggleClientStatus(Client client, bool newValue) async {
    final updated = client.copyWith(
      isActive: newValue,
      updatedAt: DateTime.now(),
    );

    try {
      await _clientService.update(updated);

      setState(() {
        final index = _clients.indexWhere((c) => c.id == client.id);
        if (index != -1) {
          _clients[index] = updated;
        }
      });

      _showSnackBar(
        newValue ? "Cliente ativado." : "Cliente desativado.",
      );
    } catch (e) {
      print("❌ Erro ao alterar status: $e");
    }
  }

  // ============================================================
  // 🔵 CONFIRMAR AÇÃO
  // ============================================================
  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(title),
            content: Text(message),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ViaColors.error,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Excluir"),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ============================================================
  // 🔵 FILTRO
  // ============================================================
  List<Client> get _filteredClients {
    return _clients.where((c) {
      final matchSearch =
          c.companyName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchStatus = !_showActiveOnly || c.isActive;

      return matchSearch && matchStatus;
    }).toList();
  }

  // ============================================================
  // 🔵 SNACKBAR
  // ============================================================
  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ViaColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // 🔵 UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredClients;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes"),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: ViaColors.primary),
            onPressed: _navigateToCreate,
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
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    ClientFilterBar(
                      showActiveOnly: _showActiveOnly,
                      onToggle: (value) {
                        setState(() => _showActiveOnly = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhum cliente encontrado.",
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
                                  onToggleStatus: (newValue) =>
                                      _toggleClientStatus(
                                          client, newValue), // FIX CORRETO
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ClientDetailScreen(client: client),
                                      ),
                                    );
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
