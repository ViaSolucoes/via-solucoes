import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viasolucoes/models/user.dart';

class UserServiceSupabase {
  final supabase = Supabase.instance.client;

  // 🔵 CRIA PERFIL DO USUÁRIO NA TABELA
  Future<void> createProfile(ViaSolutionsUser user) async {
    await supabase.from('tbdUsuario').insert({
      'idUsuario': user.id,
      'nomeUsuario': user.name,
      'emailUsuario': user.email,
      'roleUsuario': user.role,
      'telefone': user.phone,
      'endereco': user.address,
      'webhookUrl': user.webhookUrl, // 🆕 NOVO CAMPO
      'criadoEm': user.createdAt.toIso8601String(),
      'atualizadoEm': user.updatedAt.toIso8601String(),
    });
  }

  // 🔵 BUSCA PERFIL DO USUÁRIO
  Future<ViaSolutionsUser?> getProfile(String id) async {
    final data = await supabase
        .from('tbdUsuario')
        .select('*')
        .eq('idUsuario', id)
        .maybeSingle();

    if (data == null) return null;

    return ViaSolutionsUser.fromJson({
      'id': data['idUsuario'],
      'name': data['nomeUsuario'],
      'email': data['emailUsuario'],
      'role': data['roleUsuario'],
      'phone': data['telefone'],
      'address': data['endereco'],
      'webhookUrl': data['webhookUrl'], // 🆕 NOVO CAMPO
      'createdAt': data['criadoEm'],
      'updatedAt': data['atualizadoEm'],
    });
  }

  // 🔵 ATUALIZAR PERFIL DO USUÁRIO
  Future<void> updateProfile(ViaSolutionsUser user) async {
    await supabase
        .from('tbdUsuario')
        .update({
      'nomeUsuario': user.name,
      'emailUsuario': user.email,
      'roleUsuario': user.role,
      'telefone': user.phone,
      'endereco': user.address,
      'webhookUrl': user.webhookUrl, // 🆕 NOVO CAMPO
      'atualizadoEm': DateTime.now().toIso8601String(),
    }).eq('idUsuario', user.id);
  }
}
