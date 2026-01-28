import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'visualizzatore_risultati.dart';
import 'visualizzatore_classifica.dart';
import 'sport_colors.dart';

class SquadrePage extends StatelessWidget {
  const SquadrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('LE SQUADRE'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Sfondo Gradiente in alto
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SportColors.blueDeep, SportColors.blueLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          SafeArea(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('squadre')
                  .orderBy('ordine')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return SchedaSquadraModern(
                      nomeSquadra: data['nome'] ?? 'Squadra',
                      linkRisultati: data['link_risultati'] ?? '',
                      linkClassifica: data['link_classifica'] ?? '',
                      allenatore: data['allenatore'] ?? '---',
                      dirigente: data['dirigente'] ?? '',
                      staff: data['staff'] ?? '',
                      elencoAtlete: data['atlete'] ?? '',
                      allenamenti: data['allenamenti'] ?? '',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SchedaSquadraModern extends StatefulWidget {
  final String nomeSquadra;
  final String linkRisultati;
  final String linkClassifica;
  final String allenatore;
  final String dirigente;
  final String staff;
  final String elencoAtlete;
  final String allenamenti;

  const SchedaSquadraModern({
    super.key,
    required this.nomeSquadra,
    required this.linkRisultati,
    required this.linkClassifica,
    required this.allenatore,
    required this.dirigente,
    required this.staff,
    required this.elencoAtlete,
    required this.allenamenti,
  });

  @override
  State<SchedaSquadraModern> createState() => _SchedaSquadraModernState();
}

class _SchedaSquadraModernState extends State<SchedaSquadraModern> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SportColors.blueDeep.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // INTESTAZIONE CARD
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 20,
              ), // Margini ridotti
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SportColors.blueDeep, SportColors.blueLight],
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: Radius.circular(_expanded ? 0 : 20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sports_volleyball,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  // USIAMO EXPANDED PER GESTIRE LO SPAZIO RIMANENTE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nomeSquadra.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2, // Permetti 2 righe
                          overflow: TextOverflow
                              .ellipsis, // Se è ancora più lungo, metti "..."
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Coach: ${widget.allenatore}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1, // Il coach sta su una riga
                          overflow: TextOverflow
                              .ellipsis, // Se troppo lungo, taglia con "..."
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // CONTENUTO NASCOSTO
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BOTTONI AZIONE
                  if (widget.linkRisultati.isNotEmpty ||
                      widget.linkClassifica.isNotEmpty)
                    Row(
                      children: [
                        if (widget.linkRisultati.isNotEmpty)
                          Expanded(
                            child: _actionButton(
                              "Risultati",
                              Icons.emoji_events,
                              SportColors.orangeAction,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => VisualizzatoreRisultatiPage(
                                      titoloPagina: "Risultati",
                                      urlSito: widget.linkRisultati,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (widget.linkRisultati.isNotEmpty &&
                            widget.linkClassifica.isNotEmpty)
                          const SizedBox(width: 10),
                        if (widget.linkClassifica.isNotEmpty)
                          Expanded(
                            child: _actionButton(
                              "Classifica",
                              Icons.leaderboard,
                              SportColors.blueDeep,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) =>
                                        VisualizzatoreClassificaPage(
                                          titoloPagina: "Classifica",
                                          urlSito: widget.linkClassifica,
                                          nomeSquadra: widget.nomeSquadra,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 20),
                  if (widget.allenamenti.isNotEmpty) ...[
                    _infoRow(
                      Icons.access_time,
                      "Allenamenti",
                      widget.allenamenti,
                    ),
                    const Divider(height: 20),
                  ],
                  _infoRow(
                    Icons.group,
                    "Roster",
                    widget.elencoAtlete.replaceAll(", ", "\n"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 12,
        ), // Padding ridotto
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      // FittedBox riduce il testo se il bottone è troppo stretto
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(text, maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
