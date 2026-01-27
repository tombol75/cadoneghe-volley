import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inizializzaWebView();
  }

  Future<void> _inizializzaWebView() async {
    // Per i risultati basta una pulizia standard
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
            // Estrae solo la tabella risultati
            await _applicaFiltroRisultati(controller);
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );

    await controller.loadRequest(Uri.parse(widget.urlSito));

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  Future<void> _applicaFiltroRisultati(WebViewController ctrl) async {
    // Selettore specifico per i risultati
    const selettore = ".results-table";

    await ctrl.runJavaScript('''
      function mostraRisultati() {
        var target = document.querySelector('$selettore');
        
        // Fallback per .wp_ultimirisultati se results-table manca
        if (!target) target = document.querySelector('.wp_ultimirisultati');

        if (target) {
          var clone = target.cloneNode(true);
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
            /* Evidenzia il punteggio */
            td:nth-child(5) { font-weight: bold; color: #0055AA; background: #e3f2fd; border-radius: 4px; }
          `;
          document.head.appendChild(style);
        }
      }
      setTimeout(mostraRisultati, 500);
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titoloPagina),
        backgroundColor:
            Colors.orange.shade600, // Colore diverso per i risultati
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_isLoading || _controller == null)
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
        ],
      ),
    );
  }
}
