import 'package:flutter/material.dart';

class DirettivoPage extends StatelessWidget {
  const DirettivoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Il Direttivo'),
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          // Titolo
          Text(
            'Organigramma Societario',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 64, 116, 188),
            ),
          ),
          SizedBox(height: 20),

          // --- MEMBRI DEL DIRETTIVO ---
          // Usiamo il nostro "timbro" personalizzato (vedi sotto)
          SchedaMembro(
            nome: "Mario Rossi",
            ruolo: "Presidente",
            icona: Icons.person,
          ),

          SchedaMembro(
            nome: "Luigi Verdi",
            ruolo: "Vice Presidente",
            icona: Icons.person_outline,
          ),

          SchedaMembro(
            nome: "Anna Bianchi",
            ruolo: "Segretaria",
            icona: Icons.edit_note,
          ),

          SchedaMembro(
            nome: "Paolo Neri",
            ruolo: "Direttore Sportivo",
            icona: Icons.sports,
          ),

          SchedaMembro(
            nome: "Giovanna Gialli",
            ruolo: "Responsabile Marketing",
            icona: Icons.campaign,
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PERSONALIZZATO PER I MEMBRI ---
class SchedaMembro extends StatelessWidget {
  final String nome;
  final String ruolo;
  final IconData icona;

  const SchedaMembro({
    super.key,
    required this.nome,
    required this.ruolo,
    required this.icona,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Dà un leggero effetto ombra 3D
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          // Cerchio colorato attorno all'icona
          backgroundColor: const Color.fromARGB(255, 64, 116, 188),
          child: Icon(icona, color: Colors.white),
        ),
        title: Text(
          nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          ruolo,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
