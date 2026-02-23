import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sport_colors.dart';

class SponsorPage extends StatelessWidget {
  const SponsorPage({super.key});

  Future<void> _apriLink(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossibile aprire il link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("I Nostri Partner"),
        backgroundColor: SportColors.blueDeep,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('sponsor').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handshake, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text(
                    "Sostienici! Diventa nostro partner.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              String nome = data['nome'] ?? "Partner";
              String descrizione = data['descrizione'] ?? "";
              String logoUrl = data['logo_url'] ?? "";
              String sito = data['sito_web'] ?? "";
              String insta = data['instagram'] ?? "";

              // Recuperiamo il colore (default bianco se manca)
              int coloreSfondoInt = data['colore_sfondo'] ?? 0xFFFFFFFF;
              Color coloreSfondo = Color(coloreSfondoInt);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 1. LOGO CON SFONDO PERSONALIZZABILE ---
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: coloreSfondo, // <--- COLORE DINAMICO QUI
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: logoUrl.isNotEmpty
                            ? Image.network(
                                logoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.business,
                                  color: Colors.grey.shade400,
                                ),
                              )
                            : Icon(
                                Icons.business,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                      ),

                      const SizedBox(width: 15),

                      // --- 2. DETTAGLI ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nome.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: SportColors.blueDeep,
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (descrizione.isNotEmpty)
                              Text(
                                descrizione,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),

                            const SizedBox(height: 12),

                            // --- 3. PULSANTI ---
                            Row(
                              children: [
                                if (sito.isNotEmpty)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _apriLink(context, sito),
                                      icon: const Icon(
                                        Icons.language,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        "Sito",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        minimumSize: const Size(0, 35),
                                      ),
                                    ),
                                  ),
                                if (sito.isNotEmpty && insta.isNotEmpty)
                                  const SizedBox(width: 8),
                                if (insta.isNotEmpty)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _apriLink(context, insta),
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        "Social",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        minimumSize: const Size(0, 35),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
