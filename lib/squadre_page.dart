import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

          if (docs.isEmpty) {
            return const Center(
              child: Text("Nessuna squadra inserita al momento."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return SchedaSquadra(
                nomeSquadra: data['nome'] ?? 'Squadra',
                allenatore: data['allenatore'] ?? '---',
                dirigente:
                    data['dirigente'] ?? '', // RECUPERIAMO IL NUOVO CAMPO
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

// --- WIDGET SCHEDA SQUADRA (AGGIORNATO CON DIRIGENTE) ---
class SchedaSquadra extends StatelessWidget {
  final String nomeSquadra;
  final String allenatore;
  final String dirigente; // Variabile nuova
  final String staff;
  final String elencoAtlete;
  final String allenamenti;

  const SchedaSquadra({
    super.key,
    required this.nomeSquadra,
    required this.allenatore,
    required this.dirigente, // Richiesta nel costruttore
    required this.staff,
    required this.elencoAtlete,
    required this.allenamenti,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: const Icon(
          Icons.sports_volleyball,
          color: Color.fromARGB(255, 64, 116, 188),
        ),
        title: Text(
          nomeSquadra,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        // Mostriamo l'allenatore subito visibile
        subtitle: Text('All: $allenatore'),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SEZIONE TECNICA (Mostriamo Dirigente qui)
                if (dirigente.isNotEmpty) ...[
                  Text(
                    "Dirigente: $dirigente",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5), // Un po' di spazio
                ],

                // SEZIONE STAFF (Se c'è altro staff)
                if (staff.isNotEmpty) ...[
                  Text(
                    "Staff: $staff",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(),
                ] else ...[
                  const Divider(), // Se non c'è staff mettiamo comunque la linea
                ],

                // SEZIONE ALLENAMENTI
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

                // SEZIONE ATLETE
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
