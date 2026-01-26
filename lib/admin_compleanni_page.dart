import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Per formattare le date (installa intl se serve)

// Nota: se 'intl' ti dà errore, aggiungilo nel terminale con: flutter pub add intl

class AdminCompleanniPage extends StatefulWidget {
  const AdminCompleanniPage({super.key});

  @override
  State<AdminCompleanniPage> createState() => _AdminCompleanniPageState();
}

class _AdminCompleanniPageState extends State<AdminCompleanniPage> {
  // Funzione Elimina
  void _eliminaAtleta(String idDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminare?"),
        content: const Text("Vuoi rimuovere questo compleanno?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('compleanni')
                  .doc(idDoc)
                  .delete();
              Navigator.pop(ctx);
            },
            child: const Text("Sì, elimina"),
          ),
        ],
      ),
    );
  }

  // Funzione Modulo
  void _apriModulo({String? idDoc, Map<String, dynamic>? dati}) {
    final nomeCtrl = TextEditingController(text: dati?['nome']);
    final squadraCtrl = TextEditingController(text: dati?['squadra']);

    // Gestione Data
    DateTime? dataSelezionata = dati != null
        ? (dati['data_nascita'] as Timestamp).toDate()
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        // StatefulBuilder serve per aggiornare la data nel popup
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  idDoc == null ? "Nuovo Compleanno" : "Modifica",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: nomeCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nome Atleta",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: squadraCtrl,
                  decoration: const InputDecoration(
                    labelText: "Squadra (es. U18)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                // SELETTORE DATA
                ListTile(
                  title: Text(
                    dataSelezionata == null
                        ? "Seleziona Data di Nascita"
                        : "Nata il: ${DateFormat('dd/MM/yyyy').format(dataSelezionata!)}",
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: dataSelezionata ?? DateTime(2010),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() {
                        // Aggiorna solo il testo nel popup
                        dataSelezionata = picked;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (nomeCtrl.text.isEmpty || dataSelezionata == null)
                      return;

                    final dataMap = {
                      'nome': nomeCtrl.text,
                      'squadra': squadraCtrl.text,
                      'data_nascita': Timestamp.fromDate(
                        dataSelezionata!,
                      ), // Firebase vuole il Timestamp
                    };

                    final navigator = Navigator.of(
                      ctx,
                    ); // Salviamo il navigator

                    if (idDoc == null) {
                      await FirebaseFirestore.instance
                          .collection('compleanni')
                          .add(dataMap);
                    } else {
                      await FirebaseFirestore.instance
                          .collection('compleanni')
                          .doc(idDoc)
                          .update(dataMap);
                    }
                    navigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 64, 116, 188),
                  ),
                  child: const Text(
                    "Salva Data",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Compleanni'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('compleanni')
            .orderBy('nome')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final dataNascita = (data['data_nascita'] as Timestamp).toDate();

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.cake, color: Colors.white),
                ),
                title: Text(data['nome']),
                subtitle: Text(
                  "${data['squadra']} - ${DateFormat('dd MMMM yyyy').format(dataNascita)}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminaAtleta(docs[index].id),
                ),
                onTap: () => _apriModulo(idDoc: docs[index].id, dati: data),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () => _apriModulo(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
