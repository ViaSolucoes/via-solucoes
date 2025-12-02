import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/services/supabase/client_service_supabase.dart';
import 'package:viasolucoes/theme.dart';

class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _clientService = ClientServiceSupabase();

  // Controllers
  final _companyNameController = TextEditingController();
  final _highwayController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _roleController = TextEditingController();
  final _addressController = TextEditingController();
  final _departmentController = TextEditingController();
  final _notesController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCnpjDialog());
  }

  // ============================================================
  // 🟦 POP-UP MODERNO (Glassmorphism)
  // ============================================================
  void _openCnpjDialog() {
    final controller = TextEditingController();
    bool isValid = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white.withOpacity(0.15),
              elevation: 0,
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Consultar CNPJ",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // CNPJ Field
                        TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "CNPJ",
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: "00.000.000/0000-00",
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          onChanged: (value) {
                            final clean = value.replaceAll(RegExp(r'\D'), '');
                            setStateDialog(() {
                              isValid = clean.length == 14;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancelar",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 14),
                            ElevatedButton(
                              onPressed: isValid
                                  ? () {
                                Navigator.pop(context);
                                _searchCnpj(controller.text);
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                disabledBackgroundColor:
                                Colors.white.withOpacity(0.2),
                              ),
                              child: const Text("Buscar"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // 🟦 CONSULTAR CNPJ — RECEITAWS
  // ============================================================
  Future<void> _searchCnpj(String raw) async {
    final cleanCnpj = raw.replaceAll(RegExp(r'\D'), '');

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final url = Uri.parse("https://www.receitaws.com.br/v1/cnpj/$cleanCnpj");

    try {
      final response = await http.get(
        url,
        headers: {"Accept": "application/json", "User-Agent": "Chrome"},
      );

      Navigator.pop(context);

      final data = jsonDecode(response.body);

      if (data["status"] == "ERROR") {
        _showError(data["message"] ?? "Erro ao consultar CNPJ.");
        return;
      }

      setState(() {
        _companyNameController.text = data["nome"] ?? "";
        _highwayController.text = data["fantasia"] ?? "";
        _cnpjController.text = cleanCnpj;
        _addressController.text =
        "${data["logradouro"] ?? ""}, ${data["numero"] ?? ""}";
        _emailController.text = data["email"] ?? "";
        _phoneController.text = data["telefone"] ?? "";
      });
    } catch (e) {
      Navigator.pop(context);
      _showError("Falha ao conectar com a API.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // 🟦 SALVAR CLIENTE
  // ============================================================
  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final client = Client(
        id: _uuid.v4(),
        companyName: _companyNameController.text.trim(),
        highway: _highwayController.text.trim(),
        cnpj: _cnpjController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        contactRole: _roleController.text.trim(),
        address: _addressController.text.trim(),
        department: _departmentController.text.trim(),
        notes: _notesController.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _clientService.add(client);

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cliente cadastrado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError("Erro ao salvar cliente.");
    }

    setState(() => _loading = false);
  }

  // ============================================================
  // UI PRINCIPAL
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Cliente")),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section("Dados da Concessionária"),
                _card(Column(
                  children: [
                    _field(_companyNameController, "Nome da Empresa",
                        required: true),
                    _field(_highwayController, "Rodovia"),
                    _field(_cnpjController, "CNPJ", required: true),
                  ],
                )),

                _section("Informações de Contato"),
                _card(Column(
                  children: [
                    _field(_contactPersonController, "Responsável"),
                    _field(_roleController, "Cargo do Responsável"),
                    _field(_emailController, "E-mail"),
                    _field(_phoneController, "Telefone"),
                  ],
                )),

                _section("Dados Complementares"),
                _card(Column(
                  children: [
                    _field(_addressController, "Endereço"),
                    _field(_departmentController, "Setor"),
                    _field(_notesController, "Observações", maxLines: 3),
                  ],
                )),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _loading ? null : _saveClient,
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Salvar Cliente"),
                ),
              ],
            ),
          ),

          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================
  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 22),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _field(TextEditingController controller, String label,
      {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) =>
        required && (v == null || v.trim().isEmpty) ? "Campo obrigatório" : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
