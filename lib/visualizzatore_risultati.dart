import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class VisualizzatoreRisultatiPage extends StatefulWidget {
  final String titoloPagina;
  final String urlSito;

  const VisualizzatoreRisultatiPage({
    super.key,
    required this.titoloPagina,
    required this.urlSito,
  });

  @override
  State<VisualizzatoreRisultatiPage> createState() =>
      _VisualizzatoreRisultatiPageState();
}

class _VisualizzatoreRisultatiPageState
    extends State<VisualizzatoreRisultatiPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  String _settimanaVisualizzata = "";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          // --- LOGICA DI RICOSTRUZIONE SET (Andata a capo automatica) ---
          onPageFinished: (String url) async {
            await _controller.runJavaScript(r'''
              var setCells = document.querySelectorAll('td:nth-child(7)');
              setCells.forEach(function(cell) {
                var spans = cell.querySelectorAll('span.parziali');
                if (spans.length > 0) {
                  var newContent = "";
                  spans.forEach(function(s) {
                    var val = s.innerText.trim();
                    if (val.length > 0) {
                      newContent += '<div style="display:block; margin: 4px 0; border-bottom: 1px solid #f0f0f0; padding-bottom: 2px;">' + val + '</div>';
                    }
                  });
                  cell.innerHTML = newContent;
                }
              });
            ''');
          },
        ),
      );

    _caricaRisultatiIntelligenti();
  }

  DateTime _getLunediSettimana(int offsetSettimane) {
    DateTime now = DateTime.now();
    int giorniDaSottrarre = now.weekday - 1;
    DateTime lunediCorrente = now.subtract(Duration(days: giorniDaSottrarre));
    return lunediCorrente.add(Duration(days: 7 * offsetSettimane));
  }

  String _formattaDataUrl(DateTime data) {
    String giorno = data.day.toString().padLeft(2, '0');
    String mese = data.month.toString().padLeft(2, '0');
    String anno = data.year.toString();
    return "$giorno%2F$mese%2F$anno";
  }

  String _formattaDataLeggibile(DateTime data) {
    String giorno = data.day.toString().padLeft(2, '0');
    String mese = data.month.toString().padLeft(2, '0');
    String anno = data.year.toString();
    return "$giorno/$mese/$anno";
  }

  Future<void> _caricaRisultatiIntelligenti() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      DateTime lunediCorrente = _getLunediSettimana(0);
      bool trovati = await _scaricaEProcessa(lunediCorrente);

      if (!trovati) {
        DateTime lunediPrecedente = _getLunediSettimana(-1);
        bool trovatiPrecedenti = await _scaricaEProcessa(lunediPrecedente);

        if (!trovatiPrecedenti) {
          throw Exception(
            "Nessun risultato trovato nelle ultime due settimane.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _scaricaEProcessa(DateTime dataLunedi) async {
    String dataUrl = _formattaDataUrl(dataLunedi);

    String urlFipav =
        "https://www.fipavpd.net/risultati-classifiche.aspx?"
        "ComitatoId=3&StId=2265&DataDa=$dataUrl&StatoGara=1&CId=&SId=45&PId=16651&btFiltro=CERCA";

    final response = await http.get(Uri.parse(urlFipav));
    if (response.statusCode != 200) return false;

    var document = parser.parse(response.body);
    var tabelle = document.querySelectorAll('table');

    StringBuffer htmlContenuto = StringBuffer();
    int tabelleValide = 0;

    for (var tabella in tabelle) {
      if (tabella.innerHtml.contains("Squadra") &&
          (tabella.innerHtml.contains("Ris") ||
              tabella.innerHtml.contains("Set"))) {
        tabelleValide++;

        String titoloCampionato = "Campionato";
        var caption = tabella.querySelector('caption');
        if (caption != null) {
          titoloCampionato = caption.text.trim();
          caption.remove();
        }

        htmlContenuto.write(
          '<h4 style="color: #d32f2f; margin-top: 25px; margin-bottom: 10px; text-transform: uppercase; border-bottom: 2px solid #eee; padding-bottom: 5px;">$titoloCampionato</h4>',
        );

        htmlContenuto.write('<div class="table-wrapper">');
        htmlContenuto.write(tabella.outerHtml);
        htmlContenuto.write('</div>');
      }
    }

    if (tabelleValide > 0) {
      String dataLeggibile = _formattaDataLeggibile(dataLunedi);

      String htmlFinale =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: 'Roboto', sans-serif; background-color: #FFFFFF; margin: 0; padding: 15px; padding-bottom: 60px; }
            h3.main-title { color: #e65100; text-align: center; margin-bottom: 5px; }
            p.sub-title { text-align: center; color: #666; font-size: 12px; margin-top: 0; margin-bottom: 20px; }
            
            .table-wrapper {
              width: 100%; overflow-x: auto;
              box-shadow: 0 2px 5px rgba(0,0,0,0.05);
              border-radius: 8px; margin-bottom: 20px; border: 1px solid #eee;
            }
            
            table { width: 100%; border-collapse: collapse; min-width: 550px; font-size: 13px; }
            
            th { background-color: #e65100; color: white; padding: 10px; text-align: center; font-size: 12px; white-space: nowrap; }
            
            td { padding: 10px; border-bottom: 1px solid #eee; color: #333; vertical-align: middle; text-align: center; }
            
            tr:nth-child(even) { background-color: #fff8e1; }
            
            td:contains("CADONEGHE"), td:contains("Cadoneghe") { font-weight: bold; color: #d32f2f; }

            /* NASCONDI SOLO GARA E G (Colonne 1 e 2) */
            th:nth-child(1), td:nth-child(1),
            th:nth-child(2), td:nth-child(2)
            { display: none; }

            /* EVIDENZIA RISULTATO */
            td:nth-child(6) { font-weight: bold; font-size: 14px; color: #e65100; background-color: #fff3e0; border-radius: 4px; }

            /* FORMATTAZIONE PARZIALI (Colonna 7) */
            td:nth-child(7) { 
              font-size: 12px; 
              color: #444; 
              font-style: italic;
              min-width: 90px;
              line-height: 1.5;
            }

            td:nth-child(4), td:nth-child(5) { text-align: left; }
          </style>
        </head>
        <body>
          <h3 class="main-title">${widget.titoloPagina}</h3>
          <p class="sub-title">Settimana del $dataLeggibile</p>
          ${htmlContenuto.toString()}
          <div style="text-align: center; margin-top: 30px; color: #999; font-size: 11px;">Dati ufficiali Fipav Padova</div>
        </body>
        </html>
      ''';

      if (mounted) {
        await _controller.loadHtmlString(
          htmlFinale,
          baseUrl: "https://www.fipavpd.net/",
        );
        setState(() {
          _isLoading = false;
          _settimanaVisualizzata = dataLeggibile;
        });
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titoloPagina),
        backgroundColor: const Color(0xFFFF8800),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _caricaRisultatiIntelligenti(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sports_volleyball,
                      color: Colors.grey,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Nessun risultato recente",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _caricaRisultatiIntelligenti(),
                      child: const Text("Riprova"),
                    ),
                  ],
                ),
              ),
            ),
          if (_errorMessage == null) WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8800)),
            ),
        ],
      ),
    );
  }
}
