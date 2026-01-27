import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VisualizzatoreClassificaPage extends StatefulWidget {
  final String titoloPagina;
  final String urlSito;
  final String nomeSquadra; // <--- NUOVO PARAMETRO

  const VisualizzatoreClassificaPage({
    super.key,
    required this.titoloPagina,
    required this.urlSito,
    required this.nomeSquadra, // <--- RICHIESTO
  });

  @override
  State<VisualizzatoreClassificaPage> createState() =>
      _VisualizzatoreClassificaPageState();
}

class _VisualizzatoreClassificaPageState
    extends State<VisualizzatoreClassificaPage> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inizializzaWebView();
  }

  Future<void> _inizializzaWebView() async {
    // 1. Pulizia e Reset
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    final controller = WebViewController();
    await controller.clearCache();
    await controller.clearLocalStorage();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            // Passiamo il nome della squadra allo script
            await _applicaFiltroClassifica(controller);
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );

    await controller.loadRequest(Uri.parse(widget.urlSito));

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  Future<void> _applicaFiltroClassifica(WebViewController ctrl) async {
    // Puliamo il nome della squadra per la ricerca (togliamo spazi extra)
    final nomeDaCercare = widget.nomeSquadra.trim();

    await ctrl.runJavaScript('''
      function trovaClassificaPerNome() {
        // Nome della squadra passato da Flutter (convertito in minuscolo per case-insensitive)
        var nomeTeam = "$nomeDaCercare".toLowerCase();
        
        // Se il nome è composto (es "U16 Bellon"), proviamo a cercare anche solo una parte significativa
        // per evitare che una piccola differenza blocchi tutto.
        // Ma per ora usiamo il nome completo per massima precisione.

        var tables = document.querySelectorAll('table');
        var tabellaVincitrice = null;
        var punteggioMax = -1;

        tables.forEach(function(tbl) {
           var testo = tbl.innerText.toLowerCase();
           var nRighe = tbl.rows.length;
           var punteggio = 0;

           // 1. DEVE ESSERE UNA CLASSIFICA
           // Deve avere "punti" e NON "squadra casa" (che è risultati)
           var eClassifica = testo.includes('punti') && !testo.includes('squadra casa');

           if (eClassifica) {
              // Base: il numero di righe (più è lunga, meglio è)
              punteggio += nRighe;

              // 2. BONUS ENORME SE CONTIENE IL NOME SQUADRA
              if (testo.includes(nomeTeam)) {
                 punteggio += 1000; // Priorità assoluta
                 console.log("Trovato nome squadra in tabella!");
              } else {
                 // Tentativo parziale: se il nome è "U16 BellonMit", cerchiamo anche solo "BellonMit"
                 // Dividiamo il nome in parole e vediamo se almeno una parola lunga (>3 caratteri) è presente
                 var parole = nomeTeam.split(' ');
                 var parolaTrovata = false;
                 for (var p of parole) {
                    if (p.length > 3 && testo.includes(p)) {
                       parolaTrovata = true;
                       break;
                    }
                 }
                 if (parolaTrovata) punteggio += 500; // Bonus medio
              }

              // DEBUG
              console.log("Tabella righe: " + nRighe + " Punteggio: " + punteggio);

              if (punteggio > punteggioMax) {
                 punteggioMax = punteggio;
                 tabellaVincitrice = tbl;
              }
           }
        });

        // Fallback Iframe
        if (!tabellaVincitrice) {
           var iframe = document.querySelector('iframe');
           if (iframe) tabellaVincitrice = iframe;
        }

        if (tabellaVincitrice) {
          var clone = tabellaVincitrice.cloneNode(true);
          document.body.innerHTML = '';
          
          var container = document.createElement('div');
          container.style.padding = '10px';
          container.style.overflowX = 'auto';
          
          container.appendChild(clone);
          document.body.appendChild(container);
          
          var style = document.createElement('style');
          style.innerHTML = `
            body { background: #fff; font-family: Helvetica, sans-serif; margin: 0; }
            table { width: 100% !important; border-collapse: collapse; min-width: 400px; }
            td, th { padding: 10px; border-bottom: 1px solid #ddd; text-align: center; font-size: 14px; }
            th { background: #0055AA; color: white; }
            tr:nth-child(even) { background: #f9f9f9; }
            /* Evidenzia la riga che contiene il nome della squadra */
            tr:contains('${widget.nomeSquadra}') { background-color: #ffeb3b !important; } 
          `;
          document.head.appendChild(style);
          
          // Script extra per evidenziare la riga della squadra (JS puro perché CSS :contains non è standard)
          var rows = document.querySelectorAll('tr');
          rows.forEach(function(row) {
             if (row.innerText.toLowerCase().includes(nomeTeam)) {
                row.style.backgroundColor = "#fff9c4"; // Giallo chiarissimo
                row.style.fontWeight = "bold";
                row.style.border = "2px solid #ff9800";
             }
          });

        } else {
           document.body.innerHTML = '<div style="padding:20px; text-align:center;"><h3>Nessuna classifica trovata per: ' + nomeTeam + '</h3></div>';
        }
      }
      
      setTimeout(trovaClassificaPerNome, 1000);
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titoloPagina),
        backgroundColor: const Color(0xFF0055AA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _controller = null;
                _isLoading = true;
              });
              _inizializzaWebView();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_isLoading || _controller == null)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF0055AA)),
            ),
        ],
      ),
    );
  }
}
