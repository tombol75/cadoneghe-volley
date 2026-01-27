import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum TipoDati { risultati, classifica }

class VisualizzatoreCampionatoPage extends StatefulWidget {
  final String titoloPagina;
  final String urlSito;
  final TipoDati tipoVisualizzazione;

  const VisualizzatoreCampionatoPage({
    super.key,
    required this.titoloPagina,
    required this.urlSito,
    required this.tipoVisualizzazione,
  });

  @override
  State<VisualizzatoreCampionatoPage> createState() =>
      _VisualizzatoreCampionatoPageState();
}

class _VisualizzatoreCampionatoPageState
    extends State<VisualizzatoreCampionatoPage> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inizializzaWebView();
  }

  Future<void> _inizializzaWebView() async {
    // 1. Pulizia Totale (Cookie)
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    // 2. Creazione
    final controller = WebViewController();

    // 3. Configurazione
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            // 4. Pulizia Cache (FONDAMENTALE per il problema "squadra bloccata")
            try {
              await controller.clearCache();
              await controller.clearLocalStorage();
            } catch (e) {
              debugPrint("Cache non cancellata: $e");
            }

            // 5. Avvio isolamento tabella
            await _applicaFiltroVisivo(controller);

            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      );

    await controller.loadRequest(Uri.parse(widget.urlSito));

    if (mounted) {
      setState(() {
        _controller = controller;
      });
    }
  }

  Future<void> _applicaFiltroVisivo(WebViewController ctrl) async {
    String selettoreCSS = "";

    // --- SELETTORI AGGIORNATI ---
    if (widget.tipoVisualizzazione == TipoDati.risultati) {
      selettoreCSS = ".results-table"; // <--- CORRETTO COME DA TUA INDICAZIONE
    } else {
      selettoreCSS = ".classifica-table";
    }

    await ctrl.runJavaScript('''
      function isolaTabella() {
        // Cerca l'elemento
        var target = document.querySelector('$selettoreCSS');
        
        // Fallback: se non trova .classifica-table, prova iframe o .wp_classifica
        if (!target && '$selettoreCSS' === '.classifica-table') {
            target = document.querySelector('.wp_classifica') || document.querySelector('iframe');
        }

        if (target) {
          var clone = target.cloneNode(true);
          
          // Pulisce la pagina
          document.body.innerHTML = '';
          
          // Crea contenitore
          var container = document.createElement('div');
          container.style.padding = '10px';
          container.style.marginTop = '10px';
          container.style.overflowX = 'auto'; 
          
          container.appendChild(clone);
          document.body.appendChild(container);
          
          // CSS PER RENDERE BELLO IL TUTTO
          var style = document.createElement('style');
          style.innerHTML = `
            body { background-color: #fff; font-family: Helvetica, Arial, sans-serif; margin: 0; }
            
            table { width: 100% !important; border-collapse: collapse !important; min-width: 400px; }
            
            td, th { 
              padding: 10px !important; 
              border-bottom: 1px solid #ddd !important; 
              font-size: 14px !important; 
              color: #333 !important; 
              text-align: center !important; 
            }
            
            th { background-color: #0055AA !important; color: white !important; }
            tr:nth-child(even) { background-color: #f9f9f9 !important; }
            iframe { width: 100% !important; height: 90vh !important; border: none !important; }
            .nascondi-mobile { display: none !important; }
            
            /* Evidenzia la colonna risultato (applicato ora a .results-table) */
            .results-table td:nth-child(5) { 
               font-weight: bold; 
               color: #0055AA; 
               background: #e3f2fd; 
               border-radius: 4px; 
            }
          `;
          document.head.appendChild(style);
        } else {
          // Opzionale: gestire caso "non trovato"
        }
      }
      
      setTimeout(isolaTabella, 500);
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
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0055AA)),
                    SizedBox(height: 20),
                    Text(
                      "Caricamento...",
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
