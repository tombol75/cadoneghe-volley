import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // FONDAMENTALE
import 'campionato_webview_page.dart';

class SquadrePage extends StatelessWidget {
  const SquadrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Nostre Squadre'),
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('squadre')
            .orderBy('ordine')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text("Nessuna squadra inserita."));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return SchedaSquadra(
                nomeSquadra: data['nome'] ?? 'Squadra',
                // Leggiamo il link (se non c'è mettiamo stringa vuota)
                linkCampionato: data['link_campionato'] ?? '',
                allenatore: data['allenatore'] ?? '---',
                dirigente: data['dirigente'] ?? '',
                staff: data['staff'] ?? '',
                elencoAtlete: data['atlete'] ?? '',
                allenamenti: data['allenamenti'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class SchedaSquadra extends StatelessWidget {
  final String nomeSquadra;
  final String linkCampionato; // Variabile nuova
  final String allenatore;
  final String dirigente;
  final String staff;
  final String elencoAtlete;
  final String allenamenti;

  const SchedaSquadra({
    super.key,
    required this.nomeSquadra,
    required this.linkCampionato, // Richiesta
    required this.allenatore,
    required this.dirigente,
    required this.staff,
    required this.elencoAtlete,
    required this.allenamenti,
  });

  // Funzione per aprire il link
  Future<void> _apriLink() async {
    if (linkCampionato.isEmpty) return;
    final Uri url = Uri.parse(linkCampionato);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Impossibile aprire il link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        leading: const Icon(
          Icons.sports_volleyball,
          color: Color.fromARGB(255, 64, 116, 188),
        ),
        title: Text(
          nomeSquadra,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('All: $allenatore'),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BOTTONE CLASSIFICA E RISULTATI ---
                if (linkCampionato.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.table_chart, color: Colors.blue),
                      label: const Text(
                        "Vedi Classifica e Risultati",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        // Navighiamo alla pagina che "pulisce" il sito
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampionatoWebviewPage(
                              url: linkCampionato,
                              nomeSquadra: nomeSquadra,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
                // ---------------------------------------

                // -------------------------------------
                if (dirigente.isNotEmpty) ...[
                  Text(
                    "Dirigente: $dirigente",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                ],

                if (staff.isNotEmpty) ...[
                  Text(
                    "Staff: $staff",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(),
                ] else
                  const Divider(),

                if (allenamenti.isNotEmpty) ...[
                  Row(
                    children: const [
                      Icon(Icons.access_time, size: 16, color: Colors.orange),
                      SizedBox(width: 5),
                      Text(
                        "ORARI ALLENAMENTO:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    allenamenti,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Divider(),
                ],

                const Text(
                  "ROSTER:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  elencoAtlete.replaceAll(", ", "\n"),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
