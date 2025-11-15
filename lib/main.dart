import 'package:flutter/material.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/screens/login_screen.dart';

void main() {
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
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
