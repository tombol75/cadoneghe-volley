import 'package:flutter/material.dart';
import 'direttivo_page.dart';
import 'squadre_page.dart'; // Importiamo la pagina delle squadre
import 'admin_direttivo_page.dart';
import 'admin_squadre_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Serve per cercare i compleanni
import 'admin_compleanni_page.dart'; // La pagina appena creata

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Appena l'app parte, controlliamo i compleanni
    // Usiamo un piccolo ritardo per aspettare che la grafica sia pronta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCompleanniOggi();
    });
  }

  Future<void> _checkCompleanniOggi() async {
    final today = DateTime.now();

    final snapshot = await FirebaseFirestore.instance
        .collection('compleanni')
        .get();

    List<String> festeggiati = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // --- CORREZIONE DI SICUREZZA ---
      // Se il campo 'data_nascita' non esiste o è nullo, saltiamo questo giro.
      if (data['data_nascita'] == null) {
        continue; // Passa al prossimo documento senza crashare
      }
      // -------------------------------

      final dataNascita = (data['data_nascita'] as Timestamp).toDate();

      if (dataNascita.day == today.day && dataNascita.month == today.month) {
        festeggiati.add("${data['nome']} (${data['squadra']})");
      }
    }

    if (festeggiati.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.pink.shade50,
          title: const Row(
            children: [
              Icon(Icons.cake, color: Colors.pink, size: 30),
              SizedBox(width: 10),
              Text("Buon Compleanno!"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Oggi facciamo gli auguri a:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              ...festeggiati.map(
                (nome) => Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Auguri! 🎉",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ... qui sotto c'è il metodo build ...
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

  // --- FUNZIONE PER LA PASSWORD (CORRETTA) ---
  void _mostraLogin(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context, // Usa il context della Home Page (VIVO)
      // QUI C'ERA L'ERRORE: Invece di (context), lo chiamiamo (dialogContext)
      // così non si confonde con quello sopra!
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Area Riservata'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Inserisci Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
              ), // Chiudiamo usando il dialogContext
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == "volley2024") {
                  // 1. Chiudiamo il popup della password
                  Navigator.pop(dialogContext);

                  // 2. APRIAMO IL MENU
                  // IMPORTANTE: Qui usiamo 'context' (quello della Home Page, che è ancora vivo),
                  // non 'dialogContext' (che è appena stato chiuso/distrutto).
                  showModalBottomSheet(
                    context: context,
                    builder: (sheetContext) {
                      // Anche qui diamo un nome diverso per sicurezza
                      return Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Pannello Admin",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // GESTISCI DIRETTIVO
                            ListTile(
                              leading: const Icon(
                                Icons.people,
                                color: Colors.blue,
                              ),
                              title: const Text("Gestisci Direttivo"),
                              onTap: () {
                                Navigator.pop(sheetContext); // Chiude il menu
                                // Usa 'context' della Home per navigare
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const AdminDirettivoPage(),
                                  ),
                                );
                              },
                            ),

                            // GESTISCI SQUADRE
                            ListTile(
                              leading: const Icon(
                                Icons.sports_volleyball,
                                color: Colors.orange,
                              ),
                              title: const Text("Gestisci Squadre"),
                              onTap: () {
                                Navigator.pop(sheetContext); // Chiude il menu
                                // Usa 'context' della Home per navigare
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const AdminSquadrePage(),
                                  ),
                                );
                              },
                            ),
                            // GESTISCI COMPLEANNI (NUOVO)
                            ListTile(
                              leading: const Icon(
                                Icons.cake,
                                color: Colors.pink,
                              ),
                              title: const Text("Registro Compleanni"),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const AdminCompleanniPage(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                } else {
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
