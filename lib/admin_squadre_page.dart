import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSquadrePage extends StatefulWidget {
  const AdminSquadrePage({super.key});

  @override
  State<AdminSquadrePage> createState() => _AdminSquadrePageState();
}

class _AdminSquadrePageState extends State<AdminSquadrePage> {
  // Funzione Elimina
  void _eliminaSquadra(String idDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminare Squadra?"),
        content: const Text(
          "Se elimini la squadra, perderai tutti i dati inseriti.",
        ),
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

  // Funzione Apri Modulo
  void _apriModulo({String? idDoc, Map<String, dynamic>? dati}) {
    final nomeCtrl = TextEditingController(text: dati?['nome']);
    final allenatoreCtrl = TextEditingController(text: dati?['allenatore']);
    final dirigenteCtrl = TextEditingController(text: dati?['dirigente']);
    final staffCtrl = TextEditingController(text: dati?['staff']);
    final atleteCtrl = TextEditingController(text: dati?['atlete']);
    final allenamentiCtrl = TextEditingController(text: dati?['allenamenti']);

    // --- DUE CONTROLLER SEPARATI PER I LINK ---
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
            crossAxisAlignment: CrossAxisAlignment.start,
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

              // --- CAMPO LINK RISULTATI ---
              TextField(
                controller: linkRisultatiCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: "Link Solo Risultati (Opzionale)",
                  hintText: "http://...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_score, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 10),

              // --- CAMPO LINK CLASSIFICA ---
              TextField(
                controller: linkClassificaCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: "Link Solo Classifica (Opzionale)",
                  hintText: "http://...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.leaderboard, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: allenatoreCtrl,
                decoration: const InputDecoration(
                  labelText: "1° Allenatore",
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
                  labelText: "Orari Allenamenti",
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

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Annulla"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (nomeCtrl.text.isEmpty) return;

                      final dataMap = {
                        'nome': nomeCtrl.text,
                        'link_risultati':
                            linkRisultatiCtrl.text, // Salvataggio Link 1
                        'link_classifica':
                            linkClassificaCtrl.text, // Salvataggio Link 2
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
        title: const Text('Gestione Squadre'),
        backgroundColor: Colors.grey[900],
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
                      onPressed: () =>
                          _apriModulo(idDoc: docs[index].id, dati: data),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        onPressed: () => _apriModulo(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
