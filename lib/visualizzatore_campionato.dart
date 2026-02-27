import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class VisualizzatoreCampionatoPage extends StatefulWidget {
  final String titoloPagina;
  final String urlSito;

  const VisualizzatoreCampionatoPage({
    super.key,
    required this.titoloPagina,
    required this.urlSito,
  });

  @override
  State<VisualizzatoreCampionatoPage> createState() =>
      _VisualizzatoreCampionatoPageState();
}

class _VisualizzatoreCampionatoPageState
    extends State<VisualizzatoreCampionatoPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // LOGICA DI RICOSTRUZIONE TOTALE DEI SET
            // Invece di modificare gli span esistenti, estraiamo i dati e
            // rifacciamo il contenuto della cella per forzare l'andata a capo.
            await _controller.runJavaScript(r'''
              var setCells = document.querySelectorAll('td.risultato-dettagli, td:nth-child(7)');
              setCells.forEach(function(cell) {
                var spans = cell.querySelectorAll('span.parziali');
                if (spans.length > 0) {
                  var newContent = "";
                  spans.forEach(function(s) {
                    var val = s.innerText.trim();
                    if (val.length > 0) {
                      // Creiamo un contenitore block per ogni set per forzare l'a capo
                      newContent += '<div style="display:block; margin: 4px 0; border-bottom: 1px solid #f0f0f0; padding-bottom: 2px;">' + val + '</div>';
                    }
                  });
                  // Sovrascriviamo l'intera cella con i nuovi blocchi puliti
                  cell.innerHTML = newContent;
                }
              });
            ''');
          },
        ),
      );

    _caricaRisultati();
  }

  Future<void> _caricaRisultati() async {
    try {
      final response = await http.get(Uri.parse(widget.urlSito));
      if (response.statusCode != 200)
        throw Exception("Errore HTTP: ${response.statusCode}");

      var document = parser.parse(response.body);
      var tabelle = document.querySelectorAll('table');
      StringBuffer htmlContenuto = StringBuffer();
      int tabelleTrovate = 0;

      for (var tabella in tabelle) {
        String testo = tabella.text.toLowerCase();
        if (testo.contains("squadra") &&
            (testo.contains("ris") || testo.contains("set"))) {
          tabelleTrovate++;
          htmlContenuto.write(
            '<div class="table-wrapper">${tabella.outerHtml}</div>',
          );
        }
      }

      if (tabelleTrovate == 0) throw Exception("Nessun calendario trovato.");

      // Ricostruzione HTML pulita per evitare errori di visualizzazione variabili Dart
      String htmlInizio = r'''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: 'Roboto', sans-serif; margin: 0; padding: 15px; background: white; }
            h3 { color: #e65100; text-align: center; margin-bottom: 20px; font-weight: bold; }
            .table-wrapper {
              width: 100%; overflow-x: auto;
              box-shadow: 0 2px 8px rgba(0,0,0,0.1);
              border-radius: 12px; margin-bottom: 25px; border: 1px solid #eee;
            }
            table { width: 100%; border-collapse: collapse; min-width: 550px; font-size: 13px; }
            th { background-color: #e65100; color: white; padding: 12px 8px; text-align: center; white-space: nowrap; }
            td { padding: 10px 6px; border-bottom: 1px solid #eee; color: #333; text-align: center; vertical-align: middle; }
            tr:nth-child(even) { background-color: #fffaf0; }
            td:contains("CADONEGHE"), td:contains("Cadoneghe") { font-weight: bold; color: #d32f2f; }
            th:nth-child(1), td:nth-child(1), th:nth-child(2), td:nth-child(2) { display: none; }
            td:nth-child(6) { font-weight: bold; color: #e65100; background: #fff3e0; font-size: 15px; }
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
      ''';

      String htmlFine = r'''
          <div style="text-align: center; margin-top: 25px; color: #999; font-size: 11px;">Dati ufficiali Fipav Padova</div>
        </body>
        </html>
      ''';

      // Composizione sicura dell'HTML finale
      String htmlTotale =
          htmlInizio +
          '<h3>${widget.titoloPagina}</h3>' +
          htmlContenuto.toString() +
          htmlFine;

      await _controller.loadHtmlString(
        htmlTotale,
        baseUrl: "https://www.fipavpd.net/",
      );
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted)
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
    }
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
            onPressed: () {
              setState(() => _isLoading = true);
              _caricaRisultati();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage == null) WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8800)),
            ),
          if (_errorMessage != null)
            Center(child: Text(_errorMessage!, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
