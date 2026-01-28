import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sport_colors.dart';

class AdminComunicazioniPage extends StatefulWidget {
  const AdminComunicazioniPage({super.key});

  @override
  State<AdminComunicazioniPage> createState() => _AdminComunicazioniPageState();
}

class _AdminComunicazioniPageState extends State<AdminComunicazioniPage> {
  void _eliminaComunicazione(String idDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminare?"),
        content: const Text("Vuoi cancellare questa comunicazione?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('comunicazioni')
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

  void _apriModulo({String? idDoc, Map<String, dynamic>? dati}) {
    final titoloCtrl = TextEditingController(text: dati?['titolo']);
    final testoCtrl = TextEditingController(text: dati?['testo']);

    // Default priorità: 3 (Verde/Info)
    int prioritaSelezionata = dati?['priorita'] ?? 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
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
                  idDoc == null ? "Nuova Comunicazione" : "Modifica",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: titoloCtrl,
                  decoration: const InputDecoration(
                    labelText: "Titolo",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: testoCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Testo del messaggio",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Priorità:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sceltaPriorita(
                      1,
                      "Alta (Popup)",
                      Colors.red,
                      prioritaSelezionata,
                      (val) => setModalState(() => prioritaSelezionata = val),
                    ),
                    _sceltaPriorita(
                      2,
                      "Media",
                      Colors.amber,
                      prioritaSelezionata,
                      (val) => setModalState(() => prioritaSelezionata = val),
                    ),
                    _sceltaPriorita(
                      3,
                      "Info",
                      Colors.green,
                      prioritaSelezionata,
                      (val) => setModalState(() => prioritaSelezionata = val),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titoloCtrl.text.isEmpty) return;
                      final dataMap = {
                        'titolo': titoloCtrl.text,
                        'testo': testoCtrl.text,
                        'priorita': prioritaSelezionata,
                        'data': FieldValue.serverTimestamp(), // Data automatica
                      };

                      if (idDoc == null) {
                        await FirebaseFirestore.instance
                            .collection('comunicazioni')
                            .add(dataMap);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('comunicazioni')
                            .doc(idDoc)
                            .update(dataMap);
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SportColors.blueDeep,
                    ),
                    child: const Text(
                      "Pubblica",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sceltaPriorita(
    int val,
    String label,
    Color color,
    int current,
    Function(int) onTap,
  ) {
    bool isSelected = val == current;
    return GestureDetector(
      onTap: () => onTap(val),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: isSelected ? color : color.withOpacity(0.2),
            child: Icon(
              Icons.priority_high,
              color: isSelected ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Comunicazioni'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('comunicazioni')
            .orderBy('data', descending: true)
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
              int priorita = data['priorita'] ?? 3;
              Color coloreIcona = priorita == 1
                  ? Colors.red
                  : (priorita == 2 ? Colors.amber : Colors.green);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: coloreIcona.withOpacity(0.2),
                  child: Icon(Icons.notifications, color: coloreIcona),
                ),
                title: Text(
                  data['titolo'] ?? '---',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data['testo'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminaComunicazione(docs[index].id),
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
