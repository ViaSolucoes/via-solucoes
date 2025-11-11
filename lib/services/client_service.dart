import 'package:viasolucoes/models/client.dart';
import 'package:uuid/uuid.dart';

class ClientService {
  final List<Client> _clients = [];
  final _uuid = const Uuid();

  Future<void> initializeSampleData() async {
    // Simula um pequeno atraso como se estivesse carregando do banco
    await Future.delayed(const Duration(milliseconds: 300));

    if (_clients.isEmpty) {
      _clients.addAll([
        Client(
          id: _uuid.v4(),
          companyName: 'Concessionária ViaOeste',
          highway: 'SP-280 – Rodovia Castelo Branco',
          cnpj: '12.345.678/0001-90',
          email: 'contato@viaoeste.com.br',
          phone: '(11) 4002-8922',
          contactPerson: 'Carlos Alberto',
          contactRole: 'Gerente de Operações',
          address: 'Km 45 – Araçariguama/SP',
          department: 'Operações',
          notes: 'Cliente ativo com contrato vigente.',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
        ),
        Client(
          id: _uuid.v4(),
          companyName: 'Rodovias SP',
          highway: 'SP-330 – Anhanguera',
          cnpj: '98.765.432/0001-10',
          email: 'contato@rodoviasp.com.br',
          phone: '(11) 3003-4040',
          contactPerson: 'Juliana Souza',
          contactRole: 'Coordenadora Técnica',
          address: 'Campinas/SP',
          department: 'Engenharia',
          notes: 'Cliente ativo com inspeções mensais.',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now(),
        ),
      ]);
    }
  }

  List<Client> getClients() => _clients;

  void addClient(Client client) {
    _clients.add(client);
  }

  void updateClient(Client updatedClient) {
    final index = _clients.indexWhere((c) => c.id == updatedClient.id);
    if (index != -1) _clients[index] = updatedClient;
  }

  void deleteClient(String id) {
    _clients.removeWhere((c) => c.id == id);
  }
}
