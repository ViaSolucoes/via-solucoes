import 'package:shared_preferences/shared_preferences.dart';
import 'package:viasolucoes/models/user.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final List<ViaSolutionsUser> _users = [];
  final _uuid = const Uuid();

  Future<void> initializeSampleData() async {
    if (_users.isNotEmpty) return;

    _users.addAll([
      ViaSolutionsUser(
        id: _uuid.v4(),
        name: 'Marco Amorim',
        email: 'eumarcoamorim@gmail.com',
        role: 'Administrador',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ViaSolutionsUser(
        id: _uuid.v4(),
        name: 'Juliana Souza',
        email: 'juliana@rodoviasp.com.br',
        role: 'Coordenadora Técnica',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  Future<ViaSolutionsUser?> authenticate(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _users.firstWhere(
            (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<ViaSolutionsUser?> getById(String id) async {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCurrentUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', id);
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }
}
