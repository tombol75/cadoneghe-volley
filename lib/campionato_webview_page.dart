import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class CampionatoWebviewPage extends StatefulWidget {
  final String url;
  final String nomeSquadra;

  const CampionatoWebviewPage({
    super.key,
    required this.url,
    required this.nomeSquadra,
  });

  @override
  State<CampionatoWebviewPage> createState() => _CampionatoWebviewPageState();
}

class _CampionatoWebviewPageState extends State<CampionatoWebviewPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _costruisciPaginaConSessione();
  }

  Future<void> _costruisciPaginaConSessione() async {
    try {
      // 1. SCARICHIAMO LA PAGINA PRINCIPALE
      final uriPrincipale = Uri.parse(widget.url);
      final response = await http.get(uriPrincipale);

      if (response.statusCode != 200) {
        throw Exception("Errore server: ${response.statusCode}");
      }

      // --- PUNTO CRUCIALE: SALVIAMO IL COOKIE DI SESSIONE ---
      // Il server ci dà un 'pass' (es. ASP.NET_SessionId) che dobbiamo riusare
      String? cookieDiSessione = response.headers['set-cookie'];

      // Puliamo il cookie per tenerci solo la parte importante (prima del ;)
      if (cookieDiSessione != null && cookieDiSessione.contains(';')) {
        cookieDiSessione = cookieDiSessione.split(';')[0];
      }
      // ------------------------------------------------------

      // 2. ANALIZZIAMO IL CODICE HTML
      var document = parser.parse(response.body);

      // RECUPERIAMO LO STILE (CSS)
      String stiliOriginali = "";
      var head = document.querySelector('head');
      if (head != null) {
        // Aggiungiamo il base href per far funzionare immagini e css relativi
        stiliOriginali += '<base href="http://www.pallavolocadoneghe.it/">';
        stiliOriginali += head.innerHtml;
      }

      var tabellaRisultati = document.querySelector('.results-table');
      var tabellaClassifica = document.querySelector('.classifica-table');

      // 3. RECUPERO CLASSIFICA (IFRAME + COOKIE)
      if (tabellaClassifica == null) {
        var iframe = document.querySelector('iframe');
        if (iframe != null) {
          String? src = iframe.attributes['src'];

          // Costruiamo l'URL completo dell'iframe
          if (src != null && !src.startsWith('http')) {
            src = "http://www.pallavolocadoneghe.it/$src";
          }

          if (src != null) {
            try {
              // --- QUI USIAMO IL COOKIE SALVATO ---
              // Facciamo la richiesta fingendo di essere la stessa sessione di prima
              final respIframe = await http.get(
                Uri.parse(src),
                headers: {
                  'Cookie': cookieDiSessione ?? '', // Passiamo il biscotto!
                },
              );

              var docIframe = parser.parse(respIframe.body);
              var tabIframe =
                  docIframe.querySelector('.classifica-table') ??
                  docIframe.querySelector('table');

              if (tabIframe != null) {
                tabellaClassifica = tabIframe;
              }
            } catch (e) {
              debugPrint("Errore iframe: $e");
            }
          }
        }
      }

      // 4. ASSEMBLAGGIO FINALE HTML
      String htmlFinale =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          $stiliOriginali
          <style>
            body { background-color: #fff !important; padding: 10px; padding-bottom: 50px; }
            h3.app-title { 
              color: #4074bc; 
              border-bottom: 2px solid #4074bc; 
              padding-bottom: 5px; 
              margin-top: 30px; 
              font-family: Arial, sans-serif;
              font-weight: bold;
            }
            .table-responsive { overflow-x: auto; display: block; width: 100%; margin-bottom: 20px; }
          </style>
        </head>
        <body>
          
          <h3 class="app-title">Ultimi Risultati</h3>
          <div class="table-responsive">
            ${tabellaRisultati?.outerHtml ?? "<p>Dati risultati non disponibili.</p>"}
          </div>

          <h3 class="app-title">Classifica</h3>
          <div class="table-responsive">
            ${tabellaClassifica?.outerHtml ?? "<p>Classifica non disponibile al momento.</p>"}
          </div>

        </body>
        </html>
      ''';

      _caricaInWebView(htmlFinale);
    } catch (e) {
      setState(() {
        _errorMessage = "Errore: $e";
        _isLoading = false;
      });
    }
  }

  void _caricaInWebView(String htmlContent) {
    final controller = WebViewController();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadHtmlString(
      htmlContent,
      baseUrl: 'http://www.pallavolocadoneghe.it/',
    );

    if (mounted) {
      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeSquadra),
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _controller = null;
                _errorMessage = null;
              });
              _costruisciPaginaConSessione();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),

          if (_controller != null && _errorMessage == null)
            WebViewWidget(controller: _controller!),

          if (_isLoading)
            Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 15),
                    Text(
                      "Caricamento dati...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
