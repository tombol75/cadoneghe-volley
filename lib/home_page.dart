import 'package:flutter/material.dart';
import 'direttivo_page.dart';
import 'squadre_page.dart'; // Importiamo la pagina delle squadre
import 'admin_direttivo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APP Cadoneghe Volley'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings,
            ), // Icona Lucchetto/Admin
            onPressed: () {
              _mostraLogin(context); // Chiama la funzione password
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            Image.asset('assets/images/logo.png', height: 150),

            const SizedBox(height: 20),

            const Text(
              'Cadoneghe Volley',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            // ... logo e titolo sopra ...
            const SizedBox(height: 40),

            // BOTTONE 1: DIRETTIVO (Nuovo)
            SizedBox(
              // Uso SizedBox per dare una larghezza fissa ai bottoni
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DirettivoPage(),
                    ),
                  );
                },
                child: const Text('Il Direttivo'),
              ),
            ),

            const SizedBox(height: 15),

            // BOTTONE 2: SQUADRE
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SquadrePage(),
                    ),
                  );
                },
                child: const Text('Le Nostre Squadre'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNZIONE PER LA PASSWORD ---
  void _mostraLogin(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Area Riservata'),
          content: TextField(
            controller: passwordController,
            obscureText: true, // Nasconde il testo (puntini)
            decoration: const InputDecoration(hintText: "Inserisci Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Chiude
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                // CONTROLLO PASSWORD (Semplice per ora)
                if (passwordController.text == "volley2024") {
                  Navigator.pop(context); // Chiude il popup
                  // Va alla pagina di inserimento
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDirettivoPage(),
                    ),
                  );
                } else {
                  // Password sbagliata
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password Errata!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Entra'),
            ),
          ],
        );
      },
    );
  }
}
