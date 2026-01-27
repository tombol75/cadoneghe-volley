import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'visualizzatore_risultati.dart';
import 'visualizzatore_classifica.dart';
// Rimuovi: import 'visualizzatore_campionato.dart';

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

                // --- MODIFICA: LEGGIAMO I DUE LINK SEPARATI ---
                linkRisultati: data['link_risultati'] ?? '',
                linkClassifica: data['link_classifica'] ?? '',

                // ----------------------------------------------
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
  final String linkRisultati; // <--- Variabile specifica
  final String linkClassifica; // <--- Variabile specifica
  final String allenatore;
  final String dirigente;
  final String staff;
  final String elencoAtlete;
  final String allenamenti;

  const SchedaSquadra({
    super.key,
    required this.nomeSquadra,
    required this.linkRisultati, // <--- Richiesto
    required this.linkClassifica, // <--- Richiesto
    required this.allenatore,
    required this.dirigente,
    required this.staff,
    required this.elencoAtlete,
    required this.allenamenti,
  });

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
                // --- BLOCCO BOTTONI INTELLIGENTI ---
                // Mostriamo la riga solo se almeno un link esiste
                if (linkRisultati.isNotEmpty || linkClassifica.isNotEmpty) ...[
                  Row(
                    children: [
                      // 1. BOTTONE RISULTATI (Solo se c'è il link)
                      // BOTTONE 1: RISULTATI
                      if (linkRisultati.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.sports_score, size: 18),
                            label: const Text("Risultati"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // CHIAMA IL VISUALIZZATORE RISULTATI
                                  builder: (context) =>
                                      VisualizzatoreRisultatiPage(
                                        titoloPagina: "Risultati $nomeSquadra",
                                        urlSito: linkRisultati,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),

                      if (linkRisultati.isNotEmpty && linkClassifica.isNotEmpty)
                        const SizedBox(width: 10),

                      // BOTTONE 2: CLASSIFICA
                      if (linkClassifica.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.leaderboard, size: 18),
                            label: const Text("Classifica"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0055AA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // CHIAMA IL VISUALIZZATORE CLASSIFICA CON IL NOME SQUADRA
                                  builder: (context) =>
                                      VisualizzatoreClassificaPage(
                                        titoloPagina: "Classifica $nomeSquadra",
                                        urlSito: linkClassifica,
                                        nomeSquadra:
                                            nomeSquadra, // <--- FONDAMENTALE: Passiamo il nome esatto
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],

                // ---------------------------------------
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
