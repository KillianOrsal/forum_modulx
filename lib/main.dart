import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ModulXForumApp());
}

class ModulXForumApp extends StatelessWidget {
  const ModulXForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ModulX Forum - Modèles 3D',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
