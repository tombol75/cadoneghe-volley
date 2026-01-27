import 'package:flutter/material.dart';

class TabellonePage extends StatefulWidget {
  const TabellonePage({super.key});

  @override
  State<TabellonePage> createState() => _TabellonePageState();
}

class _TabellonePageState extends State<TabellonePage> {
  // --- STATO DEL GIOCO ---
  final String nomeCasa = "Cadoneghe";
  final String nomeOspiti = "Ospiti";
  int puntiCasa = 0;
  int puntiOspiti = 0;
  int setCasa = 0;
  int setOspiti = 0;
  int numeroSet = 1;
  bool battutaCasa = true;
  int timeoutCasa = 0;
  int timeoutOspiti = 0;
  List<String> storicoSet = [];

  // --- LOGICA DI GIOCO (Invariata) ---
  void _incrementaPunti(bool isCasa) {
    setState(() {
      if (isCasa) {
        puntiCasa++;
        battutaCasa = true;
      } else {
        puntiOspiti++;
        battutaCasa = false;
      }
      _controllaFineSet();
    });
  }

  void _decrementaPunti(bool isCasa) {
    setState(() {
      if (isCasa && puntiCasa > 0) puntiCasa--;
      if (!isCasa && puntiOspiti > 0) puntiOspiti--;
    });
  }

  void _chiamaTimeout(bool isCasa) {
    setState(() {
      if (isCasa) {
        if (timeoutCasa < 2) timeoutCasa++;
      } else {
        if (timeoutOspiti < 2) timeoutOspiti++;
      }
    });
  }

  void _cambiaBattutaManuale() {
    setState(() {
      battutaCasa = !battutaCasa;
    });
  }

  void _controllaFineSet() {
    int targetPunti = (numeroSet == 5) ? 15 : 25;
    if (puntiCasa >= targetPunti && (puntiCasa - puntiOspiti) >= 2) {
      _chiudiSet(vincitoreCasa: true);
    } else if (puntiOspiti >= targetPunti && (puntiOspiti - puntiCasa) >= 2) {
      _chiudiSet(vincitoreCasa: false);
    }
  }

  void _chiudiSet({required bool vincitoreCasa}) {
    String risultato =
        "Set $numeroSet: $puntiCasa - $puntiOspiti (${vincitoreCasa ? nomeCasa : nomeOspiti})";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Set $numeroSet Terminato!"),
        content: Text(
          "Vince il set: ${vincitoreCasa ? nomeCasa : nomeOspiti}\nPunteggio: $puntiCasa - $puntiOspiti",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _nuovoSet(vincitoreCasa);
            },
            child: const Text("Inizia Nuovo Set"),
          ),
        ],
      ),
    );

    setState(() {
      storicoSet.add(risultato);
      if (vincitoreCasa) {
        setCasa++;
      } else {
        setOspiti++;
      }
    });
  }

  void _nuovoSet(bool chiHaVintoUltimo) {
    setState(() {
      if (setCasa == 3 || setOspiti == 3) {
        _partitaFinita();
      } else {
        numeroSet++;
        puntiCasa = 0;
        puntiOspiti = 0;
        timeoutCasa = 0;
        timeoutOspiti = 0;
        battutaCasa = !chiHaVintoUltimo;
      }
    });
  }

  void _partitaFinita() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("PARTITA CONCLUSA!"),
        content: Text(
          "Vince: ${setCasa > setOspiti ? nomeCasa : nomeOspiti}\nRisultato Set: $setCasa - $setOspiti",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetPartita();
            },
            child: const Text("Nuova Partita"),
          ),
        ],
      ),
    );
  }

  void _resetPartita() {
    setState(() {
      puntiCasa = 0;
      puntiOspiti = 0;
      setCasa = 0;
      setOspiti = 0;
      numeroSet = 1;
      timeoutCasa = 0;
      timeoutOspiti = 0;
      storicoSet.clear();
      battutaCasa = true;
    });
  }

  // --- INTERFACCIA RESPONSIVE ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar ridotta in landscape per guadagnare spazio
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).orientation == Orientation.landscape ? 40 : 56,
        ),
        child: AppBar(
          title: const Text("Tabellone", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text("Reset Partita?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(c);
                          _resetPartita();
                        },
                        child: const Text("Sì"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLandscape = constraints.maxWidth > constraints.maxHeight;

          if (isLandscape) {
            // --- LAYOUT ORIZZONTALE SUPER COMPATTO ---
            return Row(
              children: [
                // TABELLONE (Flex 3)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Header Set piccolino
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        color: Colors.grey[850],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "SET $numeroSet",
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "SET: $setCasa - $setOspiti",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Squadre
                      Expanded(
                        child: Row(
                          children: [
                            _buildCompactColumn(
                              nomeCasa,
                              puntiCasa,
                              true,
                              Colors.blue[700]!,
                              timeoutCasa,
                              battutaCasa,
                            ),
                            Container(width: 1, color: Colors.white24),
                            _buildCompactColumn(
                              nomeOspiti,
                              puntiOspiti,
                              false,
                              Colors.red[700]!,
                              timeoutOspiti,
                              !battutaCasa,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // STORICO (Flex 1)
                Container(width: 1, color: Colors.white24),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.black54,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount: storicoSet.length,
                      itemBuilder: (ctx, index) => Text(
                        storicoSet[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // --- LAYOUT VERTICALE CLASSICO (Con Scroll) ---
            return Column(
              children: [
                _buildHeaderInfo(isLandscape: false),
                Expanded(
                  child: Row(
                    children: [
                      _buildVerticalColumn(
                        nomeCasa,
                        puntiCasa,
                        true,
                        Colors.blue[700]!,
                        timeoutCasa,
                        battutaCasa,
                      ),
                      Container(width: 2, color: Colors.white24),
                      _buildVerticalColumn(
                        nomeOspiti,
                        puntiOspiti,
                        false,
                        Colors.red[700]!,
                        timeoutOspiti,
                        !battutaCasa,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 120, child: _buildHistoryLog()),
              ],
            );
          }
        },
      ),
    );
  }

  // --- WIDGET PER LANDSCAPE (COMPATTO) ---
  Widget _buildCompactColumn(
    String nome,
    int punti,
    bool isCasa,
    Color color,
    int timeouts,
    bool inBattuta,
  ) {
    return Expanded(
      child: Container(
        color: color.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Distribuisce lo spazio
          children: [
            // RIGA 1: NOME + BATTUTA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (inBattuta)
                  const Icon(
                    Icons.sports_volleyball,
                    color: Colors.white,
                    size: 14,
                  ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    nome,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!inBattuta)
                  GestureDetector(
                    onTap: _cambiaBattutaManuale,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white30,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),

            // RIGA 2: PUNTEGGIO (Che prende tutto lo spazio possibile)
            Expanded(
              child: GestureDetector(
                onTap: () => _incrementaPunti(isCasa),
                child: FittedBox(
                  fit: BoxFit.contain, // Si adatta senza uscire dai bordi
                  child: Text(
                    "$punti",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // RIGA 3: BOTTONI E TIMEOUT
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Meno
                InkWell(
                  onTap: () => _decrementaPunti(isCasa),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Più
                InkWell(
                  onTap: () => _incrementaPunti(isCasa),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(Icons.add, color: color, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Timeout compatto
            InkWell(
              onTap: timeouts < 2 ? () => _chiamaTimeout(isCasa) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: timeouts < 2 ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Timeout ($timeouts/2)",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PER PORTRAIT (CLASSICO) ---
  Widget _buildVerticalColumn(
    String nome,
    int punti,
    bool isCasa,
    Color color,
    int timeouts,
    bool inBattuta,
  ) {
    return Expanded(
      child: Container(
        color: color.withOpacity(0.2),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  nome,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Opacity(
                  opacity: inBattuta ? 1.0 : 0.0,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_volleyball,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 5),
                      Text("BATTUTA", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                if (!inBattuta)
                  TextButton(
                    onPressed: _cambiaBattutaManuale,
                    child: const Text(
                      "Forza Battuta",
                      style: TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                  ),

                GestureDetector(
                  onTap: () => _incrementaPunti(isCasa),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "$punti",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _decrementaPunti(isCasa),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.white24,
                      ),
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _incrementaPunti(isCasa),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.white,
                      ),
                      child: Icon(Icons.add, color: color, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: timeouts < 2 ? () => _chiamaTimeout(isCasa) : null,
                  icon: const Icon(Icons.timer),
                  label: Text("CHIAMA ($timeouts/2)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET COMUNI ---
  Widget _buildHeaderInfo({required bool isLandscape}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isLandscape ? 5 : 10),
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "SET $numeroSet",
            style: TextStyle(
              color: Colors.yellow,
              fontSize: isLandscape ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "VINTI: $setCasa - $setOspiti",
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 16 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLog() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Storico Set:",
            style: TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: storicoSet.length,
              itemBuilder: (ctx, index) => Text(
                storicoSet[index],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
