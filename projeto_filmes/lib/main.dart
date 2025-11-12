import 'package:flutter/material.dart';
import 'screens/lista_filmes_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FilmeApp());
}

class FilmeApp extends StatelessWidget {
  const FilmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Filmes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ListaFilmesScreen(),
    );
  }
}