import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importante per il database

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
      // Qui inizia la magia: StreamBuilder ascolta il database
      body: StreamBuilder(
        // Chiediamo la collezione 'direttivo' ordinata per il campo 'ordine'
        stream: FirebaseFirestore.instance
            .collection('direttivo')
            .orderBy('ordine')
            .snapshots(),

        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // 1. Se sta caricando o ci sono errori
          if (snapshot.hasError) {
            return const Center(child: Text('Qualcosa è andato storto'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Rotellina che gira
          }

          // 2. Se i dati sono arrivati ma la lista è vuota
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nessun membro del direttivo trovato'),
            );
          }

          // 3. SE ABBIAMO I DATI: Costruiamo la lista
          final documenti = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: documenti.length,
            itemBuilder: (context, index) {
              // Prendiamo i dati del singolo documento
              var data = documenti[index].data() as Map<String, dynamic>;

              // Recuperiamo i campi (usiamo dei valori di default se mancano)
              String nome = data['nome'] ?? 'Sconosciuto';
              String ruolo = data['ruolo'] ?? 'Membro';

              return SchedaMembro(
                nome: nome,
                ruolo: ruolo,
                icona: _scegliIcona(ruolo), // Funzione intelligente per l'icona
              );
            },
          );
        },
      ),
    );
  }

  // Funzione che sceglie l'icona in base al ruolo scritto nel database
  IconData _scegliIcona(String ruolo) {
    ruolo = ruolo
        .toLowerCase(); // Trasformiamo tutto in minuscolo per facilitare il controllo
    if (ruolo.contains('presidente')) return Icons.person;
    if (ruolo.contains('vice')) return Icons.person_outline;
    if (ruolo.contains('segretaria') || ruolo.contains('segretario'))
      return Icons.edit_note;
    if (ruolo.contains('sportivo')) return Icons.sports_volleyball;
    if (ruolo.contains('marketing')) return Icons.campaign;
    return Icons.account_circle; // Icona generica per tutti gli altri
  }
}

// --- WIDGET SCHEDA MEMBRO (Uguale a prima) ---
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
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
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
