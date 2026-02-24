import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'direttivo_page.dart';
import 'squadre_page.dart';
import 'admin_direttivo_page.dart';
import 'admin_squadre_page.dart';
import 'admin_compleanni_page.dart';
import 'admin_comunicazioni_page.dart';
import 'admin_documenti_page.dart';
import 'admin_sponsor_page.dart';
import 'comunicazioni_page.dart';
import 'documenti_page.dart';
import 'sponsor_page.dart';
import 'tabellone_page.dart';
import 'visualizzatore_gare.dart';
import 'visualizzatore_risultati.dart';
import 'contatti_page.dart';
import 'sport_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _myAppId; // UID ufficiale di Firebase per l'allowlist

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkComunicazioniUrgenti();
      _inizializzaAppId();
    });
  }

  // --- INIZIALIZZAZIONE ID DISPOSITIVO TRAMITE FIREBASE AUTH ---
  Future<void> _inizializzaAppId() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInAnonymously();
      if (mounted) {
        setState(() {
          _myAppId = userCredential.user?.uid;
        });
      }
    } catch (e) {
      debugPrint("Errore generazione ID Firebase: $e");
    }
  }

  // --- CONTROLLO NEWS URGENTI ---
  Future<void> _checkComunicazioniUrgenti() async {
    try {
      var query = await FirebaseFirestore.instance
          .collection('comunicazioni')
          .where('priorita', isEqualTo: 1)
          .orderBy('data', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        var doc = query.docs.first;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getString('ultima_news_urgente_letta') != doc.id) {
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        doc['titolo'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  doc['testo'],
                  style: const TextStyle(fontSize: 16),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      await prefs.setString(
                        'ultima_news_urgente_letta',
                        doc.id,
                      );
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text("HO LETTO"),
                  ),
                ],
              ),
            );
          }
        }
      }
      if (mounted) _checkCompleanniOggi();
    } catch (_) {
      if (mounted) _checkCompleanniOggi();
    }
  }

  // --- LOGICA COMPLEANNI ---
  Future<void> _checkCompleanniOggi() async {
    final now = DateTime.now();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('compleanni')
          .get();
      List<String> festeggiati = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['data_nascita'] != null) {
          DateTime dataNascita = (data['data_nascita'] as Timestamp).toDate();
          if (dataNascita.day == now.day && dataNascita.month == now.month) {
            festeggiati.add("${data['nome']} (${data['squadra']})");
          }
        }
      }
      if (festeggiati.isNotEmpty && mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.pink.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.cake, color: Colors.pink, size: 30),
                SizedBox(width: 10),
                Text(
                  "Buon Compleanno!",
                  style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: festeggiati
                  .map(
                    (f) => Text(
                      "• $f",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                  .toList(),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Auguri!"),
              ),
            ],
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260.0,
            pinned: true,
            backgroundColor: SportColors.blueDeep,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "CADONEGHE VOLLEY",
                style: TextStyle(
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SportColors.blueLight, SportColors.blueDeep],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_round.png',
                    height: 120,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                ),
                onPressed: () => _mostraLoginAllowlist(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Match Center",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        context,
                        "Avvisi & News",
                        Icons.campaign,
                        Colors.purple,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ComunicazioniPage(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        "Prossime Gare",
                        Icons.calendar_today,
                        SportColors.blueDeep,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VisualizzatoreGarePage(
                              titoloPagina: "Prossime Gare",
                              urlSito: "http://www.pallavolocadoneghe.it/",
                              selettoreCss: ".wp_prossimepartite",
                            ),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        "Ultimi Risultati",
                        Icons.emoji_events,
                        SportColors.orangeAction,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VisualizzatoreRisultatiPage(
                              titoloPagina: "Ultimi Risultati",
                              urlSito: "http://www.pallavolocadoneghe.it/",
                            ),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        "Segnapunti",
                        Icons.scoreboard,
                        Colors.redAccent,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TabellonePage(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        "Area Download",
                        Icons.cloud_download,
                        Colors.teal,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DocumentiPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Esplora il Club",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  _buildBigBannerBtn(
                    context,
                    title: "LE NOSTRE SQUADRE",
                    subtitle: "Roster, classifiche e orari",
                    icon: Icons.groups,
                    gradientColors: [
                      SportColors.orangeAction,
                      Colors.deepOrange,
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SquadrePage()),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildBigBannerBtn(
                    context,
                    title: "STAFF",
                    subtitle: "Chi siamo e organizzazione",
                    icon: Icons.account_balance,
                    gradientColors: [
                      SportColors.blueDeep,
                      SportColors.blueLight,
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DirettivoPage()),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildBigBannerBtn(
                    context,
                    title: "I NOSTRI PARTNER",
                    subtitle: "Sponsor e collaborazioni",
                    icon: Icons.handshake,
                    gradientColors: [Colors.indigo, Colors.blueAccent],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SponsorPage()),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildBigBannerBtn(
                    context,
                    title: "CONTATTACI",
                    subtitle: "Invia SMS e Segnalazioni",
                    icon: Icons.sms,
                    gradientColors: [Colors.green, Colors.teal],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContattiPage()),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigBannerBtn(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: gradientColors),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 45, color: Colors.white70),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostraLoginAllowlist(BuildContext context) {
    if (_myAppId == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Accesso Amministratore"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("UID Dispositivo:"),
            const SizedBox(height: 10),
            SelectableText(
              _myAppId!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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
              var doc = await FirebaseFirestore.instance
                  .collection('admin_allowlist')
                  .doc(_myAppId)
                  .get();
              if (doc.exists) {
                if (mounted) {
                  Navigator.pop(ctx);
                  _mostraPannelloAdmin(context);
                }
              } else {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Accesso Negato."),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            child: const Text("Verifica"),
          ),
        ],
      ),
    );
  }

  void _mostraPannelloAdmin(BuildContext context) {
    final NavigatorState mainNavigator = Navigator.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        void navigaVerso(Widget pagina) {
          Navigator.pop(sheetContext);
          mainNavigator.push(MaterialPageRoute(builder: (_) => pagina));
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pannello Admin",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.campaign, color: Colors.purple),
                title: const Text("Gestisci Comunicazioni"),
                onTap: () => navigaVerso(const AdminComunicazioniPage()),
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Colors.teal),
                title: const Text("Gestisci Documenti"),
                onTap: () => navigaVerso(const AdminDocumentiPage()),
              ),
              ListTile(
                leading: const Icon(Icons.handshake, color: Colors.indigo),
                title: const Text("Gestisci Sponsor"),
                onTap: () => navigaVerso(const AdminSponsorPage()),
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text("Gestisci Direttivo"),
                onTap: () => navigaVerso(const AdminDirettivoPage()),
              ),
              ListTile(
                leading: const Icon(
                  Icons.sports_volleyball,
                  color: Colors.orange,
                ),
                title: const Text("Gestisci Squadre"),
                onTap: () => navigaVerso(const AdminSquadrePage()),
              ),
              ListTile(
                leading: const Icon(Icons.cake, color: Colors.pink),
                title: const Text("Registro Compleanni"),
                onTap: () => navigaVerso(const AdminCompleanniPage()),
              ),
            ],
          ),
        );
      },
    );
  }
}
