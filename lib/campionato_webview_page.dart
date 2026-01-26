import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 1. Inizializziamo il Controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);

            // --- SCRIPT DI RITAGLIO (Invariato) ---
            await _controller.runJavaScript('''
              var risultati = document.querySelector('.results-table');
              var classifica = document.querySelector('.classifica-table');
              
              var content = document.createElement('div');
              content.style.padding = '10px';
              content.style.fontFamily = 'Arial, sans-serif';

              function addTable(element, titolo) {
                if (element) {
                  var h3 = document.createElement('h3');
                  h3.innerText = titolo;
                  h3.style.color = '#0056b3';
                  h3.style.marginTop = '20px';
                  h3.style.borderBottom = '2px solid #0056b3';
                  content.appendChild(h3);

                  var scrollDiv = document.createElement('div');
                  scrollDiv.style.overflowX = 'auto'; 
                  scrollDiv.style.marginBottom = '20px';
                  
                  scrollDiv.appendChild(element.cloneNode(true));
                  content.appendChild(scrollDiv);
                }
              }

              addTable(risultati, 'Ultimi Risultati');
              addTable(classifica, 'Classifica Attuale');

              if (content.hasChildNodes()) {
                document.body.innerHTML = ''; 
                document.body.appendChild(content); 
                document.body.style.backgroundColor = 'white';
              }
            ''');
          },
        ),
      );

    // 2. PULIZIA DELLA CACHE E COOKIE (La parte nuova Fondamentale)
    _pulisciECarica();
  }

  // Creiamo una funzione asincrona separata per pulire e caricare
  Future<void> _pulisciECarica() async {
    // Cancella i cookie (resetta la sessione ASP.NET)
    await WebViewCookieManager().clearCookies();
    // Cancella la cache (evita che mostri dati vecchi)
    await _controller.clearCache();

    // 3. TRUCCO ANTI-CACHE URL
    // Aggiungiamo un numero casuale alla fine dell'URL per ingannare il browser
    // e costringerlo a scaricare la pagina fresca dal server.
    String urlFresco = widget.url;
    if (urlFresco.contains('?')) {
      urlFresco += "&anticache=${DateTime.now().millisecondsSinceEpoch}";
    } else {
      urlFresco += "?anticache=${DateTime.now().millisecondsSinceEpoch}";
    }

    // Carica la pagina
    _controller.loadRequest(Uri.parse(urlFresco));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeSquadra),
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
