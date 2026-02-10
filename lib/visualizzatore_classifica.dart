import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class VisualizzatoreClassificaPage extends StatefulWidget {
  final String titoloPagina;
  final String urlSito;
  final String nomeSquadra;

  const VisualizzatoreClassificaPage({
    super.key,
    required this.titoloPagina,
    required this.urlSito,
    required this.nomeSquadra,
  });

  @override
  State<VisualizzatoreClassificaPage> createState() =>
      _VisualizzatoreClassificaPageState();
}

class _VisualizzatoreClassificaPageState
    extends State<VisualizzatoreClassificaPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF));

    _caricaClassifica();
  }

  Future<void> _caricaClassifica() async {
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
        // Cerca tabella con "Punti", "PG" e che non sia "squadra casa" (quella è risultati)
        if (testo.contains("punti") &&
            testo.contains("pg") &&
            !testo.contains("squadra casa")) {
          tabelleTrovate++;
          htmlContenuto.write(
            '<div class="table-wrapper">${tabella.outerHtml}</div>',
          );
        }
      }

      if (tabelleTrovate == 0) throw Exception("Classifica non trovata.");

      // Nome squadra per evidenziazione
      String teamNameJS = widget.nomeSquadra.replaceAll("'", "\\'");

      String htmlFinale =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: 'Roboto', sans-serif; margin: 0; padding: 15px; }
            h3 { color: #0055AA; text-align: center; margin-bottom: 20px; }
            
            .table-wrapper {
              width: 100%; overflow-x: auto;
              box-shadow: 0 2px 5px rgba(0,0,0,0.1);
              border-radius: 8px; margin-bottom: 20px; border: 1px solid #eee;
            }
            
            table { width: 100%; border-collapse: collapse; min-width: 400px; font-size: 13px; }
            
            th { background-color: #0055AA; color: white; padding: 10px; text-align: center; white-space: nowrap; }
            td { padding: 8px; border-bottom: 1px solid #eee; color: #333; text-align: center; vertical-align: middle; }
            tr:nth-child(even) { background-color: #f9f9f9; }
            
            tr.highlight { background-color: #fff9c4 !important; font-weight: bold; border: 2px solid #ffb300; }
            td:nth-child(2) { font-weight: bold; color: #0055AA; font-size: 14px; }
            td:nth-child(1) { text-align: left; }
          </style>
        </head>
        <body>
          <h3>${widget.titoloPagina}</h3>
          ${htmlContenuto.toString()}
          <div style="text-align: center; margin-top: 20px; color: #999; font-size: 11px;">Dati Fipav Padova</div>

          <script>
            var rows = document.querySelectorAll('tr');
            var search = "$teamNameJS".toLowerCase();
            var searchParts = search.split(" ");
            
            rows.forEach(function(row) {
              var text = row.innerText.toLowerCase();
              var found = false;
              if (text.includes("cadoneghe")) {
                 for(var part of searchParts) {
                    if (part.length > 2 && text.includes(part)) { found = true; break; }
                 }
                 if (search.length < 4) found = true;
              }
              if (found) row.classList.add('highlight');
            });
          </script>
        </body>
        </html>
      ''';

      await _controller.loadHtmlString(
        htmlFinale,
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
        backgroundColor: const Color(0xFF0055AA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaClassifica,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage == null) WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF0055AA)),
            ),
          if (_errorMessage != null)
            Center(child: Text(_errorMessage!, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
