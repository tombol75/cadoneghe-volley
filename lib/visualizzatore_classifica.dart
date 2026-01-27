import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VisualizzatoreClassificaPage extends StatefulWidget {
  final String titoloPagina;
  final String urlSito;

  const VisualizzatoreClassificaPage({
    super.key,
    required this.titoloPagina,
    required this.urlSito,
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
    // 1. Pulizia standard (come nei risultati)
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    final controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            // Pulizia cache per sicurezza (non fa mai male)
            try {
              await controller.clearCache();
              await controller.clearLocalStorage();
            } catch (e) {
              debugPrint("Errore cache: $e");
            }

            // 2. Applichiamo LO STESSO filtro dei risultati
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
    // UNICA DIFFERENZA: Il nome della classe
    const selettore = ".classifica-table";

    // Questo script è identico al 100% a quello dei risultati
    await ctrl.runJavaScript('''
      function mostraClassifica() {
        // Cerca l'elemento
        var target = document.querySelector('$selettore');
        
        // Fallback: se non trova .classifica-table, prova .wp_classifica
        if (!target) target = document.querySelector('.wp_classifica');

        if (target) {
          var clone = target.cloneNode(true);
          
          // Svuota tutto
          document.body.innerHTML = '';
          
          // Crea contenitore
          var container = document.createElement('div');
          container.style.padding = '10px';
          container.style.overflowX = 'auto';
          
          container.appendChild(clone);
          document.body.appendChild(container);
          
          // Stile identico ai risultati
          var style = document.createElement('style');
          style.innerHTML = `
            body { background: #fff; font-family: Helvetica, sans-serif; margin: 0; }
            table { width: 100% !important; border-collapse: collapse; min-width: 400px; }
            td, th { padding: 10px; border-bottom: 1px solid #ddd; text-align: center; font-size: 14px; }
            th { background: #0055AA; color: white; }
            tr:nth-child(even) { background: #f9f9f9; }
          `;
          document.head.appendChild(style);
        }
      }
      setTimeout(mostraClassifica, 500);
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titoloPagina),
        backgroundColor: const Color(0xFF0055AA), // Blu per la classifica
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
