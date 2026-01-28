import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sport_colors.dart';

class AdminDocumentiPage extends StatefulWidget {
  const AdminDocumentiPage({super.key});

  @override
  State<AdminDocumentiPage> createState() => _AdminDocumentiPageState();
}

class _AdminDocumentiPageState extends State<AdminDocumentiPage> {
  // Elimina documento
  void _eliminaDocumento(String idDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminare?"),
        content: const Text("Vuoi rimuovere questo documento dalla lista?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('documenti')
                  .doc(idDoc)
                  .delete();
              Navigator.pop(ctx);
            },
            child: const Text(
              "Sì, elimina",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Modulo Inserimento
  void _apriModulo({String? idDoc, Map<String, dynamic>? dati}) {
    final titoloCtrl = TextEditingController(text: dati?['titolo']);
    final descCtrl = TextEditingController(text: dati?['descrizione']);
    final urlCtrl = TextEditingController(text: dati?['url']);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              idDoc == null ? "Nuovo Documento" : "Modifica Documento",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: titoloCtrl,
              decoration: const InputDecoration(
                labelText: "Nome Documento (es. Modulo Iscrizione)",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: "Breve Descrizione (Opzionale)",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: urlCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: "Link al file (URL)",
                hintText: "http://www.pallavolocadoneghe.it/docs/mod1.pdf",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titoloCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text("Titolo e URL sono obbligatori"),
                      ),
                    );
                    return;
                  }

                  final dataMap = {
                    'titolo': titoloCtrl.text,
                    'descrizione': descCtrl.text,
                    'url': urlCtrl.text,
                    'data': FieldValue.serverTimestamp(),
                  };

                  if (idDoc == null) {
                    await FirebaseFirestore.instance
                        .collection('documenti')
                        .add(dataMap);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('documenti')
                        .doc(idDoc)
                        .update(dataMap);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportColors.blueDeep,
                ),
                child: const Text(
                  "Salva Documento",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Documenti'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('documenti')
            .orderBy('data', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty)
            return const Center(child: Text("Nessun documento inserito."));

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.description, color: Colors.white),
                ),
                title: Text(
                  data['titolo'] ?? '---',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data['url'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminaDocumento(docs[index].id),
                ),
                onTap: () => _apriModulo(idDoc: docs[index].id, dati: data),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SportColors.blueDeep,
        onPressed: () => _apriModulo(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
