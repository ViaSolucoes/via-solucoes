import 'package:viasolucoes/models/client.dart';

/// A mock service that manages clients locally in memory.
/// This will later be replaced by the Supabase integration.
class ClientService {
  final List<Client> _clients = [];

  /// Returns all clients.
  List<Client> getClients() {
    return List.unmodifiable(_clients);
  }

  /// Adds a new client to the list.
  void addClient(Client client) {
    _clients.add(client);
    print('[ClientService] Added client: ${client.companyName}');
  }

  /// Updates an existing client by ID.
  void updateClient(Client updatedClient) {
    final index = _clients.indexWhere((c) => c.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      print('[ClientService] Updated client: ${updatedClient.companyName}');
    } else {
      print('[ClientService] Client not found for update: ${updatedClient.id}');
    }
  }

  /// Deletes a client by ID.
  void deleteClient(String id) {
    _clients.removeWhere((client) => client.id == id);
    print('[ClientService] Deleted client with id: $id');
  }

  /// Clears all clients (for testing purposes).
  void clearClients() {
    _clients.clear();
    print('[ClientService] Cleared all clients');
  }
}
