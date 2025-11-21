import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:viasolucoes/screens/login_screen.dart';
import 'package:viasolucoes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Necessário para datas em pt_BR
  await initializeDateFormatting('pt_BR', null);

  runApp(const ViaSolucoesApp());
}

class ViaSolucoesApp extends StatelessWidget {
  const ViaSolucoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Via Soluções',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,

      // 🌎 LOCALE DO APP
      locale: const Locale('pt', 'BR'),

      // 🔥 ESSENCIAIS PARA FUNCIONAR O DATE PICKER EM PORTUGUÊS
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('pt', 'BR'),
      ],

      // Tela inicial correta
      home: const LoginScreen(),
    );
  }
}
