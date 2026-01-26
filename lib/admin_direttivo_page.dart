import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDirettivoPage extends StatefulWidget {
  const AdminDirettivoPage({super.key});

  @override
  State<AdminDirettivoPage> createState() => _AdminDirettivoPageState();
}

class _AdminDirettivoPageState extends State<AdminDirettivoPage> {
  // --- 1. FUNZIONE PER ELIMINARE ---
  void _eliminaMembro(String idDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sei sicuro?"),
        content: const Text(
          "Vuoi davvero eliminare questo membro? L'azione è irreversibile.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // COMANDO MAGICO PER CANCELLARE
              await FirebaseFirestore.instance
                  .collection('direttivo')
                  .doc(idDoc)
                  .delete();
              Navigator.pop(ctx); // Chiude l'avviso
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Membro eliminato!"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 2. FUNZIONE UNICA PER AGGIUNGERE O MODIFICARE ---
  // Se passiamo un 'idDoc', siamo in modifica. Se è null, siamo in creazione.
  // --- 2. FUNZIONE UNICA PER AGGIUNGERE O MODIFICARE (CORRETTA) ---
  void _apriModulo({String? idDoc, String? nomeAttuale, String? ruoloAttuale}) {
    final TextEditingController nomeCtrl = TextEditingController(
      text: nomeAttuale,
    );
    final TextEditingController ruoloCtrl = TextEditingController(
      text: ruoloAttuale,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Per far salire la tastiera senza coprire tutto
      // Ho rimosso la riga 'padding' da qui perché dava errore
      builder: (ctx) => Padding(
        // IL PADDING VA QUI:
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          // Questo serve a spingere su il contenuto quando esce la tastiera:
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              idDoc == null ? "Nuovo Membro" : "Modifica Membro",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(
                labelText: "Nome e Cognome",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ruoloCtrl,
              decoration: const InputDecoration(
                labelText: "Ruolo",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // --- I BOTTONI DI SALVATAGGIO ---
            // --- I BOTTONI DI SALVATAGGIO (CORRETTO CON WRAP) ---
            // Usiamo Wrap invece di Row così se non ci stanno vanno a capo
            Wrap(
              alignment: WrapAlignment.end, // Allinea tutto a destra
              spacing: 10, // Spazio orizzontale tra i bottoni
              runSpacing: 10, // Spazio verticale se vanno a capo
              crossAxisAlignment:
                  WrapCrossAlignment.center, // Allinea verticalmente al centro
              children: [
                // Tasto Annulla
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Annulla"),
                ),

                // Se stiamo creando, mostriamo il tasto "Salva e Nuovo"
                if (idDoc == null)
                  OutlinedButton(
                    onPressed: () async {
                      if (nomeCtrl.text.isEmpty) return;
                      await _salvaSuFirebase(
                        null,
                        nomeCtrl.text,
                        ruoloCtrl.text,
                      );
                      // Puliamo solo i campi
                      nomeCtrl.clear();
                      ruoloCtrl.clear();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Salvato! Inserisci il prossimo."),
                          ),
                        );
                      }
                    },
                    child: const Text("Salva e Nuovo"),
                  ),

                // Tasto Salva Finale
                ElevatedButton(
                  onPressed: () async {
                    if (nomeCtrl.text.isEmpty) return;
                    await _salvaSuFirebase(
                      idDoc,
                      nomeCtrl.text,
                      ruoloCtrl.text,
                    );
                    if (mounted) Navigator.pop(ctx); // Chiude il modulo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 64, 116, 188),
                  ),
                  child: const Text(
                    "Salva e Chiudi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Logica di salvataggio (distingue tra Create e Update)
  Future<void> _salvaSuFirebase(String? id, String nome, String ruolo) async {
    final collection = FirebaseFirestore.instance.collection('direttivo');

    if (id == null) {
      // CREAZIONE NUOVO
      await collection.add({
        'nome': nome,
        'ruolo': ruolo,
        'ordine': 99,
        'data_inserimento': FieldValue.serverTimestamp(),
      });
    } else {
      // AGGIORNAMENTO ESISTENTE
      await collection.doc(id).update({'nome': nome, 'ruolo': ruolo});
    }
  }

  // --- 3. L'INTERFACCIA PRINCIPALE (LISTA) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Direttivo'),
        backgroundColor: Colors.grey[900], // Admin scuro per distinguerlo
        foregroundColor: Colors.white,
      ),
      // LISTA IN TEMPO REALE
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('direttivo')
            .orderBy('ordine')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("Nessun membro inserito. Premi + per iniziare."),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final id = docs[index]
                  .id; // L'ID del documento serve per modificare/eliminare

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Text((index + 1).toString()), // Numero progressivo
                ),
                title: Text(
                  data['nome'] ?? '---',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data['ruolo'] ?? '---'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tasto MODIFICA
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _apriModulo(
                        idDoc: id,
                        nomeAttuale: data['nome'],
                        ruoloAttuale: data['ruolo'],
                      ),
                    ),
                    // Tasto ELIMINA
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminaMembro(id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      // IL TASTONE PER AGGIUNGERE
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        onPressed: () => _apriModulo(), // Apre il modulo vuoto
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
