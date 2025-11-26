import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:viasolucoes/supabase/supabase_client.dart';
import 'package:viasolucoes/screens/auth/login_screen.dart';
import 'package:viasolucoes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Necessário para datas em pt_BR (DatePicker, formatação etc.)
  await initializeDateFormatting('pt_BR', null);

  // 🔥 Inicialização do Supabase
  await SupabaseConfig.initialize();

  runApp(const ViaSolucoesApp());
}

class ViaSolucoesApp extends StatelessWidget {
  const ViaSolucoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Via Soluções',
      debugShowCheckedModeBanner: false,

      // Tema global
      theme: lightTheme,
      // theme: lightTheme.copyWith(useMaterial3: true),  // Opcional

      // 🌎 Locale padrão em Português do Brasil
      locale: const Locale('pt', 'BR'),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('pt', 'BR'),
      ],

      // Tela inicial
      home: const LoginScreen(),
    );
  }
}
