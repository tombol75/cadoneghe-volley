import 'package:flutter/material.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            'ELENCO SQUADRE 2024/25',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 64, 116, 188),
            ),
          ),
          SizedBox(height: 20),

          // --- LISTA SQUADRE ---
          SchedaSquadra(
            nomeSquadra: "Under 18 Femminile",
            allenatore: "Marco Bianchi",
            staff: "2° All: Giulia Neri\nDir: Paolo Gialli",
            elencoAtlete:
                "Francesca, Elena, Sofia, Martina, Giorgia, Chiara, Sara",
          ),

          SchedaSquadra(
            nomeSquadra: "Prima Divisione",
            allenatore: "Roberto Blu",
            staff: "Dir: Anna Rosa",
            elencoAtlete: "Alice, Beatrice, Clara, Daniela, Elisa",
          ),

          SchedaSquadra(
            nomeSquadra: "Under 14",
            allenatore: "Laura Gialli",
            staff: "Dir: Marco Nero",
            elencoAtlete: "Giulia, Paola, Marta, Serena",
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PERSONALIZZATO (IL "TIMBRO") ---
class SchedaSquadra extends StatelessWidget {
  final String nomeSquadra;
  final String allenatore;
  final String staff;
  final String elencoAtlete;

  const SchedaSquadra({
    super.key,
    required this.nomeSquadra,
    required this.allenatore,
    required this.staff,
    required this.elencoAtlete,
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
        subtitle: Text('All: $allenatore'),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "STAFF:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(staff),
                const Divider(),
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
