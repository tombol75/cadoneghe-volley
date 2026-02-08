import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom; // Necessario per manipolare il DOM

class VisualizzatoreGarePage extends StatefulWidget {
  final String titoloPagina;
  final String urlSito;
  final String selettoreCss;

  const VisualizzatoreGarePage({
    super.key,
    required this.titoloPagina,
    required this.urlSito,
    required this.selettoreCss,
  });

  @override
  State<VisualizzatoreGarePage> createState() => _VisualizzatoreGarePageState();
}

class _VisualizzatoreGarePageState extends State<VisualizzatoreGarePage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF)); // Sfondo bianco pulito

    _caricaETrasformaSito();
  }

  Future<void> _caricaETrasformaSito() async {
    try {
      final response = await http.get(Uri.parse(widget.urlSito));

      if (response.statusCode != 200) {
        throw Exception("Errore server: ${response.statusCode}");
      }

      var document = parser.parse(response.body);

      // Cerchiamo la tabella specifica
      var elementoTarget = document.querySelector(widget.selettoreCss);

      if (elementoTarget == null) {
        throw Exception("Elemento '${widget.selettoreCss}' non trovato.");
      }

      // --- NUOVA LOGICA: ESPLICITARE INFO GARA ---
      // Cerchiamo tutte le immagini dentro la tabella (le icone info)
      List<dom.Element> immagini = elementoTarget.querySelectorAll('img');

      for (var img in immagini) {
        // Spesso le info sono in 'title' o 'alt'
        String? infoText = img.attributes['title'];
        if (infoText == null || infoText.isEmpty) {
          infoText = img.attributes['alt'];
        }

        // Se abbiamo trovato del testo (es. "Dom 12/02 ore 15:00...")
        if (infoText != null && infoText.isNotEmpty && infoText != "info") {
          // Creiamo un nuovo elemento HTML (div) con il testo
          // Usiamo un po' di CSS per renderlo leggibile
          var nuovoElemento = dom.Element.html(
            '<div style="font-size: 13px; color: #0055AA; font-weight: bold; background-color: #e3f2fd; padding: 5px; border-radius: 4px; margin-top: 5px; display: inline-block;">$infoText</div>',
          );

          // Sostituiamo l'immagine (icona) con il testo esplicito
          img.replaceWith(nuovoElemento);
        } else {
          // Se non c'è testo utile, rimuoviamo l'icona per pulizia
          img.remove();
        }
      }
      // -------------------------------------------

      // --- HTML PULITO: VERSIONE TABELLA CLASSICA ---
      String htmlPulito =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { 
              font-family: 'Helvetica', 'Arial', sans-serif; 
              background-color: #FFFFFF; 
              margin: 0; 
              padding: 10px; 
            }
            
            /* Contenitore per lo scroll orizzontale se la tabella è larga */
            .table-wrapper {
              width: 100%;
              overflow-x: auto; /* Abilita scroll orizzontale */
              -webkit-overflow-scrolling: touch; /* Scroll fluido su iOS */
              box-shadow: 0 0 10px rgba(0,0,0,0.05);
            }

            /* STILE TABELLA CLASSICO */
            table { 
              width: 100%; 
              border-collapse: collapse; 
              min-width: 500px; /* Forza la larghezza minima per non schiacciare il testo */
              font-size: 14px;
            }

            /* Intestazione (se presente) */
            th {
              background-color: #0055AA;
              color: white;
              padding: 12px 8px;
              text-align: left;
            }

            /* Celle */
            td { 
              padding: 10px 8px; 
              border-bottom: 1px solid #ddd;
              color: #333;
              vertical-align: middle;
            }

            /* Righe alterne per leggibilità (Zebra striping) */
            tr:nth-child(even) { background-color: #f9f9f9; }
            tr:hover { background-color: #f1f1f1; }

            /* Miglioramenti estetici specifici */
            
            /* Link e testo in blu */
            a { text-decoration: none; color: #0055AA; font-weight: bold; }
            
            /* Evidenzia Risultato (solitamente colonna centrale) */
            td strong, td b {
              color: #000;
              font-weight: bold;
            }

            /* Rimuoviamo eventuali immagini residue che non siamo riusciti a sostituire */
            img { display: none; }

          </style>
        </head>
        <body>
          <h3 style="color: #0055AA; text-align: center; margin-bottom: 15px;">${widget.titoloPagina}</h3>
          
          <div class="table-wrapper">
            ${elementoTarget.outerHtml}
          </div>

        </body>
        </html>
      ''';

      await _controller.loadHtmlString(htmlPulito, baseUrl: widget.urlSito);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                _isLoading = true;
                _errorMessage = null;
              });
              _caricaETrasformaSito();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Errore caricamento dati:\n$_errorMessage",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),

          if (_errorMessage == null) WebViewWidget(controller: _controller),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF0055AA)),
            ),
        ],
      ),
    );
  }
}
