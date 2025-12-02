import 'package:flutter_test/flutter_test.dart';
import 'package:viasolucoes/services/client_service.dart';
import 'package:viasolucoes/models/client.dart';

void main() {
  group('ClientService Tests', () {
    late ClientService service;

    setUp(() {
      service = ClientService();
    });

    test('getClients() deve retornar lista vazia inicial', () {
      final clients = service.getClients();
      expect(clients, isA<List<Client>>());
      expect(clients.isEmpty, true);
    });

    test('addClient() deve adicionar um cliente corretamente', () {
      final client = Client(
        id: "1",
        companyName: "Empresa Teste",
        highway: "SP-000",
        cnpj: "00.000.000/0000-00",
        email: "email@teste.com",
        phone: "123",
        contactPerson: "Fulano",
        contactRole: "Gerente",
        address: "Rua x",
        department: "Depto",
        notes: "Obs",
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      service.addClient(client);

      final clients = service.getClients();
      expect(clients.length, 1);
      expect(clients.first.id, "1");
      expect(clients.first.companyName, "Empresa Teste");
    });

    test('updateClient() deve atualizar cliente existente', () {
      final clientOriginal = Client(
        id: "1",
        companyName: "Original",
        highway: "SP-100",
        cnpj: "00.000.000/0001-00",
        email: "original@teste.com",
        phone: "111",
        contactPerson: "Pessoa",
        contactRole: "Cargo",
        address: "Endereço",
        department: "Depto",
        notes: "Notas",
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      service.addClient(clientOriginal);

      final clientAtualizado = Client(
        id: "1",
        companyName: "Atualizado",
        highway: "SP-100",
        cnpj: "00.000.000/0001-00",
        email: "novo@teste.com",
        phone: "222",
        contactPerson: "Pessoa Nova",
        contactRole: "Novo Cargo",
        address: "Novo Endereço",
        department: "Novo Depto",
        notes: "Novas Notas",
        isActive: false,
        createdAt: clientOriginal.createdAt,
        updatedAt: DateTime.now(),
      );

      service.updateClient(clientAtualizado);

      final clients = service.getClients();
      expect(clients.length, 1);
      final updated = clients.first;

      expect(updated.companyName, "Atualizado");
      expect(updated.email, "novo@teste.com");
      expect(updated.isActive, false);
    });

    test('deleteClient() deve remover cliente corretamente', () {
      final client1 = Client(
        id: "1",
        companyName: "Cliente 1",
        highway: "SP-000",
        cnpj: "00",
        email: "",
        phone: "",
        contactPerson: "",
        contactRole: "",
        address: "",
        department: "",
        notes: "",
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final client2 = Client(
        id: "2",
        companyName: "Cliente 2",
        highway: "SP-000",
        cnpj: "00",
        email: "",
        phone: "",
        contactPerson: "",
        contactRole: "",
        address: "",
        department: "",
        notes: "",
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      service.addClient(client1);
      service.addClient(client2);

      service.deleteClient("1");

      final clients = service.getClients();

      expect(clients.length, 1);
      expect(clients.first.id, "2");
    });
  });
}
