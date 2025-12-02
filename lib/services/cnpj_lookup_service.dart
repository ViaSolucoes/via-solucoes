import 'dart:convert';
import 'package:http/http.dart' as http;

class CnpjLookupService {
  static const String _baseUrl = "https://brasilapi.com.br/api/cnpj/v1/";

  Future<Map<String, dynamic>?> fetchCnpj(String cnpj) async {
    try {
      final cleanCnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

      final url = Uri.parse("$_baseUrl$cleanCnpj");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Erro ${response.statusCode}: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Erro ao buscar CNPJ: $e");
      return null;
    }
  }
}
