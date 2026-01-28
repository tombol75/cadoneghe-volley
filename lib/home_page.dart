import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORTANTE
import 'direttivo_page.dart';
import 'squadre_page.dart';
import 'admin_direttivo_page.dart';
import 'admin_squadre_page.dart';
import 'admin_compleanni_page.dart';
import 'admin_comunicazioni_page.dart'; // NUOVA PAGINA ADMIN
import 'comunicazioni_page.dart'; // NUOVA PAGINA USER
import 'tabellone_page.dart';
import 'visualizzatore_gare.dart';
import 'contatti_page.dart';
import 'sport_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Controllo se ci sono comunicazioni urgenti all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkComunicazioniUrgenti();
    });
  }

  // LOGICA POPUP URGENTE
  Future<void> _checkComunicazioniUrgenti() async {
    try {
      // 1. Cerco l'ultima news con priorità 1 (Alta)
      var query = await FirebaseFirestore.instance
          .collection('comunicazioni')
          .where('priorita', isEqualTo: 1)
          .orderBy('data', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        var doc = query.docs.first;
        String idNews = doc.id;
        String titolo = doc['titolo'];
        String testo = doc['testo'];

        // 2. Controllo nella memoria locale se l'ho già letta
        final prefs = await SharedPreferences.getInstance();
        String? idUltimaLetta = prefs.getString('ultima_news_urgente_letta');

        // 3. Se l'ID è diverso (quindi è una news nuova), mostro il popup
        if (idUltimaLetta != idNews) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false, // L'utente DEVE premere OK
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.red.shade50,
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
                        titolo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Text(testo, style: const TextStyle(fontSize: 16)),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      // 4. Salvo che l'ho letta
                      await prefs.setString(
                        'ultima_news_urgente_letta',
                        idNews,
                      );
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text(
                      "Ho capito",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Errore check news: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // HEADER
          SliverAppBar(
            expandedHeight: 260.0,
            floating: false,
            pinned: true,
            stretch: true,
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [SportColors.blueLight, SportColors.blueDeep],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo_round.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.sports_volleyball,
                                  size: 60,
                                  color: SportColors.blueDeep,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "CADONEGHE VOLLEY",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
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
                onPressed: () => _mostraLogin(context),
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // CORPO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
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
                        title: "Prossime Gare",
                        icon: Icons.calendar_today_rounded,
                        color: SportColors.blueDeep,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VisualizzatoreGarePage(
                              titoloPagina: "Prossime Gare",
                              urlSito: "http://www.pallavolocadoneghe.it/",
                              selettoreCss: ".wp_prossimepartite",
                            ),
                          ),
                        ),
                      ),

                      _buildActionCard(
                        context,
                        title: "Ultimi Risultati",
                        icon: Icons.emoji_events_rounded,
                        color: SportColors.orangeAction,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VisualizzatoreGarePage(
                              titoloPagina: "Ultimi Risultati",
                              urlSito: "http://www.pallavolocadoneghe.it/",
                              selettoreCss: ".wp_ultimirisultati",
                            ),
                          ),
                        ),
                      ),

                      _buildActionCard(
                        context,
                        title: "Segnapunti",
                        icon: Icons.scoreboard_rounded,
                        color: Colors.redAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TabellonePage(),
                          ),
                        ),
                      ),

                      // --- NUOVO TASTO COMUNICAZIONI ---
                      _buildActionCard(
                        context,
                        title: "News & Avvisi",
                        icon: Icons.campaign_rounded,
                        color: Colors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ComunicazioniPage(),
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
                    icon: Icons.groups_rounded,
                    gradientColors: [
                      SportColors.orangeAction,
                      Colors.deepOrange,
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SquadrePage(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildBigBannerBtn(
                    context,
                    title: "IL DIRETTIVO",
                    subtitle: "Chi siamo e organizzazione",
                    icon: Icons.account_balance_rounded,
                    gradientColors: [
                      SportColors.blueDeep,
                      SportColors.blueLight,
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DirettivoPage(),
                      ),
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
                      MaterialPageRoute(
                        builder: (context) => const ContattiPage(),
                      ),
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
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
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
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Icon(icon, size: 45, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostraLogin(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Area Riservata'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Inserisci Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == "volley2024") {
                  Navigator.pop(dialogContext);
                  showModalBottomSheet(
                    context: context,
                    builder: (sheetContext) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Pannello Admin",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListTile(
                              leading: const Icon(
                                Icons.notifications_active,
                                color: Colors.purple,
                              ),
                              title: const Text("Gestisci Comunicazioni"),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) =>
                                        const AdminComunicazioniPage(),
                                  ),
                                );
                              },
                            ), // <--- NUOVO LINK
                            ListTile(
                              leading: const Icon(
                                Icons.people,
                                color: Colors.blue,
                              ),
                              title: const Text("Gestisci Direttivo"),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const AdminDirettivoPage(),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.sports_volleyball,
                                color: Colors.orange,
                              ),
                              title: const Text("Gestisci Squadre"),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const AdminSquadrePage(),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.cake,
                                color: Colors.pink,
                              ),
                              title: const Text("Registro Compleanni"),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const AdminCompleanniPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password Errata!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Entra'),
            ),
          ],
        );
      },
    );
  }
}
