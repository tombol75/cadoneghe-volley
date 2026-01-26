import 'package:flutter/material.dart';
import 'home_page.dart'; // Importiamo il file appena creato

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadoneghe Volley App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 64, 116, 188),
        ),
        useMaterial3: true,
      ),
      // Qui diciamo: "La pagina iniziale è la HomePage"
      home: const HomePage(),
    );
  }
}
