import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSquadrePage extends StatefulWidget {
  const AdminSquadrePage({super.key});

  @override
  State<AdminSquadrePage> createState() => _AdminSquadrePageState();
}

class _AdminSquadrePageState extends State<AdminSquadrePage> {
  // Variabile locale per mostrare il numero a video
  String _numeroAttuale = "Caricamento...";

  @override
  void initState() {
    super.initState();
    _leggiNumeroDaFirebase();
  }

  // Legge il numero da Firebase all'avvio
  Future<void> _leggiNumeroDaFirebase() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('impostazioni')
          .doc('contatti')
          .get();

      if (mounted) {
        setState(() {
          if (doc.exists &&
              doc.data() != null &&
              doc.data()!.containsKey('numero')) {
            _numeroAttuale = doc.data()!['numero'].toString();
          } else {
            _numeroAttuale = "Nessun numero salvato";
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _numeroAttuale = "Errore connessione");
    }
  }

  // Apre il popup per modificare il numero
  void _apriPopupConfigurazione() {
    final numeroCtrl = TextEditingController();

    // Se c'è già un numero valido, riempiamo il campo
    if (_numeroAttuale.startsWith("+") || _numeroAttuale.startsWith("3")) {
      numeroCtrl.text = _numeroAttuale;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Configura Numero SMS"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Inserisci il cellulare della società (es. +39333...):"),
            const SizedBox(height: 10),
            TextField(
              controller: numeroCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Numero Cellulare",
                hintText: "+393471234567",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () async {
              String nuovoNumero = numeroCtrl.text.trim();

              if (nuovoNumero.isEmpty) return;

              // Salvataggio su Firebase (crea la collezione se non esiste)
              await FirebaseFirestore.instance
                  .collection('impostazioni')
                  .doc('contatti')
                  .set({'numero': nuovoNumero});

              // Aggiorna la scritta a video
              setState(() {
                _numeroAttuale = nuovoNumero;
              });

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Numero salvato correttamente!")),
              );
            },
            child: const Text("Salva Numero"),
          ),
        ],
      ),
    );
  }

  // --- GESTIONE SQUADRE (Codice Standard) ---
  void _eliminaSquadra(String idDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminare Squadra?"),
        content: const Text("Se elimini la squadra, perderai i dati."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('squadre')
                  .doc(idDoc)
                  .delete();
              Navigator.pop(ctx);
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _apriModuloSquadra({String? idDoc, Map<String, dynamic>? dati}) {
    final nomeCtrl = TextEditingController(text: dati?['nome']);
    final allenatoreCtrl = TextEditingController(text: dati?['allenatore']);
    final dirigenteCtrl = TextEditingController(text: dati?['dirigente']);
    final staffCtrl = TextEditingController(text: dati?['staff']);
    final atleteCtrl = TextEditingController(text: dati?['atlete']);
    final allenamentiCtrl = TextEditingController(text: dati?['allenamenti']);
    final linkRisultatiCtrl = TextEditingController(
      text: dati?['link_risultati'],
    );
    final linkClassificaCtrl = TextEditingController(
      text: dati?['link_classifica'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                idDoc == null ? "Nuova Squadra" : "Modifica Squadra",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(
                  labelText: "Nome Squadra",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: linkRisultatiCtrl,
                decoration: const InputDecoration(
                  labelText: "Link Risultati",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_score, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: linkClassificaCtrl,
                decoration: const InputDecoration(
                  labelText: "Link Classifica",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.leaderboard, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: allenatoreCtrl,
                decoration: const InputDecoration(
                  labelText: "Allenatore",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dirigenteCtrl,
                decoration: const InputDecoration(
                  labelText: "Dirigente",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: staffCtrl,
                decoration: const InputDecoration(
                  labelText: "Staff",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: allenamentiCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Allenamenti",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: atleteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Atlete",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nomeCtrl.text.isEmpty) return;
                  final dataMap = {
                    'nome': nomeCtrl.text,
                    'link_risultati': linkRisultatiCtrl.text,
                    'link_classifica': linkClassificaCtrl.text,
                    'allenatore': allenatoreCtrl.text,
                    'dirigente': dirigenteCtrl.text,
                    'staff': staffCtrl.text,
                    'atlete': atleteCtrl.text,
                    'allenamenti': allenamentiCtrl.text,
                    'ordine': 99,
                  };
                  if (idDoc == null) {
                    await FirebaseFirestore.instance
                        .collection('squadre')
                        .add(dataMap);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('squadre')
                        .doc(idDoc)
                        .update(dataMap);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 64, 116, 188),
                ),
                child: const Text(
                  "Salva",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amministrazione'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          // 1. ICONA IN ALTO A DESTRA
          IconButton(
            icon: const Icon(Icons.settings_phone),
            onPressed: _apriPopupConfigurazione,
            tooltip: "Configura SMS",
          ),
        ],
      ),
      body: Column(
        children: [
          // 2. BOX BEN VISIBILE IN CIMA ALLA LISTA
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100, // Colore Giallo/Ambra per risaltare
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phonelink_setup,
                  size: 40,
                  color: Colors.brown,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "NUMERO PER SMS:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _numeroAttuale,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _apriPopupConfigurazione,
                  child: const Text("MODIFICA"),
                ),
              ],
            ),
          ),

          const Divider(),

          // 3. LISTA SQUADRE
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('squadre')
                  .orderBy('ordine')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(child: Text("Nessuna squadra."));

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (ctx, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return ListTile(
                      title: Text(
                        data['nome'] ?? '---',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("All: ${data['allenatore']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _apriModuloSquadra(
                              idDoc: docs[index].id,
                              dati: data,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminaSquadra(docs[index].id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        onPressed: () => _apriModuloSquadra(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
