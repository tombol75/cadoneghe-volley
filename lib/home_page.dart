import 'package:flutter/material.dart';
import 'direttivo_page.dart';
import 'squadre_page.dart'; // Importiamo la pagina delle squadre

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APP Cadoneghe Volley'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            Image.asset('assets/images/logo.png', height: 150),

            const SizedBox(height: 20),

            const Text(
              'Volley Club App',
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
}
