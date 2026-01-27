import 'package:flutter/material.dart';
import 'direttivo_page.dart';
import 'squadre_page.dart';
import 'admin_direttivo_page.dart';
import 'admin_squadre_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_compleanni_page.dart';
import 'sito_risultati_last_gare.dart'; // Assicurati che questo file esista
import 'pagina_contatti.dart'; // <--- IMPORTANTE: Importiamo la nuova pagina contatti
import 'tabellone_page.dart';
import 'visualizzatore_gare.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCompleanniOggi();
    });
  }

  Future<void> _checkCompleanniOggi() async {
    final today = DateTime.now();
    // Nota: Assicurati che la collezione esista su Firebase
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('compleanni')
          .get();
      List<String> festeggiati = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['data_nascita'] == null) continue;

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
    } catch (e) {
      print("Errore controllo compleanni (forse offline o permessi): $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'APP Cadoneghe Volley',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0055AA), // Blu istituzionale
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              _mostraLogin(context);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5), // Sfondo grigio chiaro
      body: SingleChildScrollView(
        // Aggiunto per evitare errori se lo schermo è piccolo
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Image.asset('assets/images/logo.png', height: 150),

                const SizedBox(height: 20),

                const Text(
                  'Cadoneghe Volley',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 30),

                // --- BOTTONI CLASSICI (DIRETTIVO E SQUADRE) ---
                // Li mantengo come pulsanti standard ma leggermente migliorati
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DirettivoPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Il Direttivo',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SquadrePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Le Nostre Squadre',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const Divider(), // Linea divisoria estetica
                const SizedBox(height: 20),

                // --- NUOVI BOTTONI STILIZZATI (GARE E RISULTATI) ---

                // 1. Prossime Gare
                _buildMenuButton(
                  context: context,
                  titolo: "Prossime Gare",
                  icona: Icons.calendar_month_outlined,
                  coloreIcona: Colors.blueAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VisualizzatoreGarePage(
                          titoloPagina: "Prossime Gare",
                          // URL della pagina dove sono presenti ENTRAMBE le tabelle
                          urlSito: "http://www.pallavolocadoneghe.it/",
                          // Selettore specifico per le prossime partite
                          selettoreCss: ".wp_prossimepartite",
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                // 2. Risultati Ultime Gare
                _buildMenuButton(
                  context: context,
                  titolo: "Risultati Ultime Gare",
                  icona: Icons.emoji_events_outlined,
                  coloreIcona: Colors.orangeAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VisualizzatoreGarePage(
                          titoloPagina: "Ultimi Risultati",
                          // Stesso URL di sopra
                          urlSito: "http://www.pallavolocadoneghe.it/",
                          // Selettore specifico per i risultati
                          selettoreCss: ".wp_ultimirisultati",
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // 4. TABELLONE SEGNAPUNTI (NUOVO)
                _buildMenuButton(
                  context: context,
                  titolo: "Segnapunti Partita",
                  icona: Icons.scoreboard_outlined, // Icona tabellone
                  coloreIcona: Colors.redAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TabellonePage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                // 3. Contattaci (NUOVO)
                _buildMenuButton(
                  context: context,
                  titolo: "Contattaci / Segnalazioni",
                  icona: Icons.mail_outline,
                  coloreIcona: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaginaContatti(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FUNZIONE LOGIN ADMIN (INVARIATA) ---
  void _mostraLogin(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == "volley2024") {
                  Navigator.pop(dialogContext);
                  showModalBottomSheet(
                    context: context,
                    builder: (sheetContext) {
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
                            ListTile(
                              leading: const Icon(
                                Icons.people,
                                color: Colors.blue,
                              ),
                              title: const Text("Gestisci Direttivo"),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const AdminDirettivoPage(),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.sports_volleyball,
                                color: Colors.orange,
                              ),
                              title: const Text("Gestisci Squadre"),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const AdminSquadrePage(),
                                  ),
                                );
                              },
                            ),
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

  // --- NUOVO WIDGET GRAFICO PER I PULSANTI ---
  Widget _buildMenuButton({
    required BuildContext context,
    required String titolo,
    required IconData icona,
    required Color coloreIcona,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: coloreIcona.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icona, color: coloreIcona, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    titolo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
