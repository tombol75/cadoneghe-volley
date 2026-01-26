import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SitoWebPage extends StatefulWidget {
  const SitoWebPage({super.key});

  @override
  State<SitoWebPage> createState() => _SitoWebPageState();
}

class _SitoWebPageState extends State<SitoWebPage> {
  late final WebViewController _controller;
  bool _isLoading = true; // Per mostrare la rotellina mentre carica

  @override
  void initState() {
    super.initState();

    // Inizializziamo il browser
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          // --- QUI AVVIENE LA MAGIA ---
          onPageFinished: (String url) async {
            // 1. Nascondiamo la rotellina di caricamento
            setState(() {
              _isLoading = false;
            });

            // 2. Iniettiamo il JavaScript per "ritagliare" il sito
            await _controller.runJavaScript('''
              // Cerchiamo l'elemento con la classe specifica
              var targetElement = document.querySelector('.wp_prossimepartite');
              
              if (targetElement) {
                // Se lo troviamo, sostituiamo tutto il body con solo questo elemento
                document.body.innerHTML = targetElement.outerHTML;
                
                // Opzionale: Aggiungiamo un po' di padding per non farlo stare attaccato ai bordi
                document.body.style.padding = '20px';
                document.body.style.backgroundColor = 'white'; // Sfondo pulito
              } else {
                // Se non lo troviamo (magari hanno cambiato il sito), non facciamo nulla
                console.log("Elemento .box-w2 non trovato");
              }
            ''');
          },
        ),
      )
      ..loadRequest(
        Uri.parse('http://www.pallavolocadoneghe.it/'),
      ); // O il sito della tua squadra
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prossime Gare'),
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        foregroundColor: Colors.white,
        actions: [
          // Tasto per ricaricare la pagina
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Il sito vero e proprio
          WebViewWidget(controller: _controller),

          // La rotellina di caricamento che sta sopra finché non finisce
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 64, 116, 188),
              ),
            ),
        ],
      ),
    );
  }
}
