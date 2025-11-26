import 'package:supabase_flutter/supabase_flutter.dart';

class UserAuthService {
  final supabase = Supabase.instance.client;

  // 🔵 LOGIN COM EMAIL E SENHA
  Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // 🔵 CADASTRO COM CONFIRMAÇÃO DE SENHA
  Future<AuthResponse?> register(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // 🔵 LOGOUT
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // 🔵 RECUPERAR ID DO USUÁRIO LOGADO
  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  // 🔵 USUÁRIO AUTENTICADO (Auth)
  User? get currentUser => supabase.auth.currentUser;
}
