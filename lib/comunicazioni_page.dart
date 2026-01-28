import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Assicurati di avere intl nel pubspec, altrimenti rimuovi la formattazione data
import 'sport_colors.dart';

class ComunicazioniPage extends StatelessWidget {
  const ComunicazioniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comunicazioni"),
        backgroundColor: SportColors.blueDeep,
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

          if (docs.isEmpty)
            return const Center(child: Text("Nessuna comunicazione recente."));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              int priorita = data['priorita'] ?? 3;
              Timestamp? ts = data['data'];
              String dataFormat = ts != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(ts.toDate())
                  : "";

              Color bgCard;
              Color iconColor;
              IconData icona;

              if (priorita == 1) {
                // URGENTE
                bgCard = Colors.red.shade50;
                iconColor = Colors.red;
                icona = Icons.campaign;
              } else if (priorita == 2) {
                // IMPORTANTE
                bgCard = Colors.amber.shade50;
                iconColor = Colors.orange;
                icona = Icons.info;
              } else {
                // INFO
                bgCard = Colors.white;
                iconColor = Colors.green;
                icona = Icons.article;
              }

              return Card(
                color: bgCard,
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icona, color: iconColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              data['titolo'] ?? "Avviso",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: SportColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['testo'] ?? "",
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          dataFormat,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
