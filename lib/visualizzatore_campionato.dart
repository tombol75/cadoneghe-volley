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
      ..setBackgroundColor(const Color(0xFFFFFFFF));

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
        // La tabella del calendario/risultati contiene "Data", "Squadra" e "Ris"
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

      String htmlFinale =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: 'Roboto', sans-serif; margin: 0; padding: 15px; }
            h3 { color: #e65100; text-align: center; margin-bottom: 20px; }
            
            .table-wrapper {
              width: 100%; overflow-x: auto;
              box-shadow: 0 2px 5px rgba(0,0,0,0.1);
              border-radius: 8px; margin-bottom: 20px; border: 1px solid #eee;
            }
            
            table { width: 100%; border-collapse: collapse; min-width: 500px; font-size: 13px; }
            
            th { background-color: #e65100; color: white; padding: 10px; text-align: center; white-space: nowrap; }
            td { padding: 10px; border-bottom: 1px solid #eee; color: #333; text-align: center; vertical-align: middle; }
            tr:nth-child(even) { background-color: #fff8e1; }
            
            td:contains("CADONEGHE"), td:contains("Cadoneghe") { font-weight: bold; color: #d32f2f; }

            /* Nascondi colonne inutili */
            th:nth-child(1), td:nth-child(1), /* Gara */
            th:nth-child(2), td:nth-child(2), /* G */
            th:nth-child(7), td:nth-child(7)  /* Set parziali */
            { display: none; }

            /* Evidenzia Risultato */
            td:nth-child(6) { font-weight: bold; color: #e65100; background: #fff3e0; border-radius: 4px; }
            
            td:nth-child(4), td:nth-child(5) { text-align: left; }
          </style>
        </head>
        <body>
          <h3>${widget.titoloPagina}</h3>
          ${htmlContenuto.toString()}
          <div style="text-align: center; margin-top: 20px; color: #999; font-size: 11px;">Dati Fipav Padova</div>
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
        backgroundColor: const Color(0xFFFF8800),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaRisultati,
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
