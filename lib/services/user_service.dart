import 'package:viasolucoes/models/user.dart';
import 'package:viasolucoes/services/storage_service.dart';

class UserService {
  final StorageService _storage = StorageService();

  Future<void> initializeSampleData() async {
    final users = await getAll();
    if (users.isEmpty) {
      final now = DateTime.now();
      final sampleUsers = [
        ViaSolutionsUser(
          id: 'user-test',
          name: 'Marco Amorim',
          email: 'eumarcoamorim@gmail.com',
          role: 'Administrador',
          createdAt: now,
          updatedAt: now,
        ),
        ViaSolutionsUser(
          id: 'user-1',
          name: 'Carlos Silva',
          email: 'carlos@viasolucoes.com.br',
          role: 'Gerente de Projetos',
          createdAt: now,
          updatedAt: now,
        ),
        ViaSolutionsUser(
          id: 'user-2',
          name: 'Ana Santos',
          email: 'ana@viasolucoes.com.br',
          role: 'Engenheira Civil',
          createdAt: now,
          updatedAt: now,
        ),
        ViaSolutionsUser(
          id: 'user-3',
          name: 'Pedro Oliveira',
          email: 'pedro@viasolucoes.com.br',
          role: 'Supervisor de Obras',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      await _storage.saveData(
        _storage.usersKey,
        sampleUsers.map((u) => u.toJson()).toList(),
      );
    }
  }

  Future<List<ViaSolutionsUser>> getAll() async {
    final data = await _storage.loadData(_storage.usersKey);
    return data.map((json) => ViaSolutionsUser.fromJson(json)).toList();
  }

  Future<ViaSolutionsUser?> getById(String id) async {
    final users = await getAll();
    return users.cast<ViaSolutionsUser?>().firstWhere(
      (u) => u?.id == id,
      orElse: () => null,
    );
  }

  Future<ViaSolutionsUser?> authenticate(String email, String password) async {
    final users = await getAll();
    final user = users.cast<ViaSolutionsUser?>().firstWhere(
      (u) => u?.email == email,
      orElse: () => null,
    );

    if (user != null) {
      // Para o usuário de teste específico, validar a senha
      if (email == 'eumarcoamorim@gmail.com') {
        if (password == '123') {
          return user;
        } else {
          return null;
        }
      }
      // Para outros usuários demo, qualquer senha serve
      return user;
    }

    return null;
  }

  Future<void> saveCurrentUser(String userId) async {
    await _storage.saveCurrentUser(userId);
  }

  Future<String?> getCurrentUserId() async {
    return await _storage.getCurrentUser();
  }

  Future<void> logout() async {
    await _storage.clearCurrentUser();
  }
}
