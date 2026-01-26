import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart'; // Importiamo il file appena creato

void main() async {
  // Questa riga serve per assicurarsi che Flutter sia pronto prima di Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inizializza Firebase usando le opzioni che ha creato prima automaticamente
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
