import 'package:flutter_test/flutter_test.dart';
import 'package:pi_5o_semestre_main/models/client.dart';

void main() {
  group('Client Model Tests', () {
    test('should convert Client to JSON and back', () {
      final client = Client(
        id: '1',
        companyName: 'Via Oeste S/A',
        highway: 'SP-280',
        cnpj: '12.345.678/0001-99',
        email: 'contact@viaoeste.com.br',
        phone: '11 3333-4444',
        contactPerson: 'Ana Souza',
        contactRole: 'Contract Manager',
        address: 'Rod. Castello Branco, km 78',
        department: 'Engineering',
        notes: 'Test conversion',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = client.toJson();
      final fromJson = Client.fromJson(json);

      expect(fromJson.companyName, equals(client.companyName));
      expect(fromJson.cnpj, equals(client.cnpj));
      expect(fromJson.isActive, isTrue);
    });

    test('should copy Client with new values', () {
      final client = Client(
        id: '1',
        companyName: 'Via Oeste',
        highway: 'SP-280',
        cnpj: '12.345.678/0001-99',
        email: 'contact@viaoeste.com.br',
        phone: '11 3333-4444',
        contactPerson: 'Ana Souza',
        contactRole: 'Manager',
        address: 'Rodovia 78',
        department: 'Engineering',
        notes: 'Old',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = client.copyWith(companyName: 'Via Oeste Updated');

      expect(updated.companyName, equals('Via Oeste Updated'));
      expect(updated.cnpj, equals(client.cnpj));
    });
  });
}
