import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sport_colors.dart';

class AdminSponsorPage extends StatefulWidget {
  const AdminSponsorPage({super.key});

  @override
  State<AdminSponsorPage> createState() => _AdminSponsorPageState();
}

class _AdminSponsorPageState extends State<AdminSponsorPage> {
  void _eliminaSponsor(String idDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminare Sponsor?"),
        content: const Text("L'azione è irreversibile."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('sponsor')
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

  void _apriModulo({String? idDoc, Map<String, dynamic>? dati}) {
    final nomeCtrl = TextEditingController(text: dati?['nome']);
    final descCtrl = TextEditingController(text: dati?['descrizione']);
    final logoCtrl = TextEditingController(text: dati?['logo_url']);
    final sitoCtrl = TextEditingController(text: dati?['sito_web']);
    final instaCtrl = TextEditingController(text: dati?['instagram']);

    // Colore di default: Bianco (0xFFFFFFFF)
    int coloreSelezionato = dati?['colore_sfondo'] ?? 0xFFFFFFFF;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        // StatefulBuilder serve per aggiornare la selezione del colore in tempo reale
        builder: (context, setModalState) {
          return Padding(
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
                    idDoc == null ? "Nuovo Sponsor" : "Modifica Sponsor",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nome Azienda",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- SELETTORE COLORE SFONDO ---
                  const Text(
                    "Sfondo per il Logo:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildColorOption(
                        0xFFFFFFFF,
                        "Bianco",
                        coloreSelezionato,
                        (val) => setModalState(() => coloreSelezionato = val),
                      ),
                      const SizedBox(width: 10),
                      _buildColorOption(
                        0xFF000000,
                        "Nero",
                        coloreSelezionato,
                        (val) => setModalState(() => coloreSelezionato = val),
                      ),
                      const SizedBox(width: 10),
                      _buildColorOption(
                        SportColors.blueDeep.value,
                        "Blu",
                        coloreSelezionato,
                        (val) => setModalState(() => coloreSelezionato = val),
                      ),
                      const SizedBox(width: 10),
                      _buildColorOption(
                        0xFFEEEEEE,
                        "Grigio",
                        coloreSelezionato,
                        (val) => setModalState(() => coloreSelezionato = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // -------------------------------
                  TextField(
                    controller: logoCtrl,
                    decoration: const InputDecoration(
                      labelText: "Link URL Logo",
                      hintText: "https://...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Presentazione",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: sitoCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: "Sito Web",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: instaCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: "Instagram",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.camera_alt),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nomeCtrl.text.isEmpty) return;

                        final dataMap = {
                          'nome': nomeCtrl.text,
                          'descrizione': descCtrl.text,
                          'logo_url': logoCtrl.text,
                          'sito_web': sitoCtrl.text,
                          'instagram': instaCtrl.text,
                          'colore_sfondo':
                              coloreSelezionato, // Salviamo il colore
                          'ordine': 99,
                        };

                        if (idDoc == null) {
                          await FirebaseFirestore.instance
                              .collection('sponsor')
                              .add(dataMap);
                        } else {
                          await FirebaseFirestore.instance
                              .collection('sponsor')
                              .doc(idDoc)
                              .update(dataMap);
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SportColors.blueDeep,
                      ),
                      child: const Text(
                        "Salva Sponsor",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget per i pallini colorati
  Widget _buildColorOption(
    int colorValue,
    String label,
    int selectedValue,
    Function(int) onTap,
  ) {
    bool isSelected = colorValue == selectedValue;
    return GestureDetector(
      onTap: () => onTap(colorValue),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1),
              boxShadow: isSelected
                  ? [
                      const BoxShadow(
                        color: Colors.blue,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.green, size: 20)
                : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Sponsor'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('sponsor').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty)
            return const Center(child: Text("Nessuno sponsor."));

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              int bgColor = data['colore_sfondo'] ?? 0xFFFFFFFF;

              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Color(bgColor), // Usa il colore salvato
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: data['logo_url'] != null && data['logo_url'].isNotEmpty
                      ? Image.network(
                          data['logo_url'],
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.business),
                ),
                title: Text(
                  data['nome'] ?? '---',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _apriModulo(idDoc: docs[index].id, dati: data),
                ),
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
