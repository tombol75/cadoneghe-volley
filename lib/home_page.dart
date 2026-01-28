import 'package:flutter/material.dart';
import 'direttivo_page.dart';
import 'squadre_page.dart';
import 'admin_direttivo_page.dart';
import 'admin_squadre_page.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_compleanni_page.dart';
import 'tabellone_page.dart';
import 'visualizzatore_gare.dart';
import 'contatti_page.dart';
//import 'main.dart'; // Importa per accedere ai CVColors
import 'sport_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // (Codice initState e _checkCompleanniOggi rimosso per brevità,
  // puoi rimetterlo se ti serve quella funzionalità)

  @override
  Widget build(BuildContext context) {
    // Usiamo una CustomScrollView per effetti di scorrimento avanzati
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- 1. HEADER APPBAR CURVO CON GRADIENTE E LOGO ---
          SliverAppBar(
            expandedHeight: 280.0,
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
                  // Aggiunge un taglio curvo in fondo all'header
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    // LOGO: Assicurati che il file esista in assets/logo_round.png o assets/images/...
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      // Se hai rinominato il file come detto prima, usa quello corretto
                      child: const CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                          'assets/images/logo_round.png',
                        ),
                      ),
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

          // --- 2. CORPO DELLA PAGINA ---
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

                  // --- GRIGLIA AZIONI RAPIDE (Gare, Risultati, Segnapunti) ---
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
                      _buildActionCard(
                        context,
                        title: "Contatti SMS",
                        icon: Icons.sms_rounded,
                        color: Colors.green,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContattiPage(),
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

                  // --- BANNER SQUADRE E DIRETTIVO ---
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NUOVO WIDGET: CARD AZIONE RAPIDA (GRIGLIA) ---
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

  // --- CORREZIONE QUI: WIDGET BANNER CON EXPANDED ---
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
                // --- AGGIUNTO EXPANDED QUI ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1, // Limita a 1 riga
                        overflow: TextOverflow
                            .ellipsis, // Aggiunge ... se troppo lungo
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize:
                              18, // Font leggermente ridotto per sicurezza
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
                // -----------------------------
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

  // FUNZIONE LOGIN
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
