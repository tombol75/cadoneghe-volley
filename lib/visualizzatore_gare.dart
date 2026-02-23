import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

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
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            // --- LOGICA DI INTERCETTAZIONE MAPPE ---
            // Intercettiamo lo schema personalizzato "app://"
            if (request.url.startsWith("app://aprimappe")) {
              final Uri uri = Uri.parse(request.url);
              final String? queryAddress = uri.queryParameters['q'];

              if (queryAddress != null && queryAddress.isNotEmpty) {
                // 1. COSTRUIAMO IL LINK UFFICIALE DI GOOGLE MAPS
                // Questo formato è universale e sicuro
                final Uri mapsUrl = Uri.parse(
                  "https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(queryAddress)}",
                );

                try {
                  // 2. PROVIAMO AD APRIRE L'APP ESTERNA
                  if (await canLaunchUrl(mapsUrl)) {
                    await launchUrl(
                      mapsUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    // Fallback: apre nel browser se non c'è l'app
                    await launchUrl(mapsUrl);
                  }
                } catch (e) {
                  debugPrint("Errore apertura mappa: $e");
                }
              }
              // IMPORTANTE: Blocchiamo la navigazione nella WebView per evitare il 404
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _caricaDatiMultiSettimana();
  }

  // Calcola il lunedì della settimana (offset: 0=corrente, 1=prossima, etc.)
  DateTime _getLunediSettimana(int offsetSettimane) {
    DateTime now = DateTime.now();
    int giorniDaSottrarre = now.weekday - 1;
    DateTime lunediCorrente = now.subtract(Duration(days: giorniDaSottrarre));
    return lunediCorrente.add(Duration(days: 7 * offsetSettimane));
  }

  // --- FUNZIONE DI PULIZIA ---
  String _pulisciIndirizzoHtml(String? rawHtml) {
    if (rawHtml == null || rawHtml.isEmpty) return "";

    try {
      var fragment = parser.parseFragment(rawHtml);

      // Rimuoviamo elementi inutili
      fragment.querySelectorAll('.designazione').forEach((e) => e.remove());
      fragment.querySelectorAll('*').forEach((e) {
        String testoElem = e.text.toLowerCase();
        if (testoElem.contains('arbitro') || testoElem.contains('designato')) {
          e.remove();
        }
      });

      // Sostituiamo <br> con trattini
      fragment.querySelectorAll('br').forEach((br) {
        br.replaceWith(dom.Text(' - '));
      });

      String testoPuro = fragment.text ?? "";
      testoPuro = testoPuro
          .replaceAll("Arbitro designato", "")
          .replaceAll("Arbitro associato", "");

      return testoPuro.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (e) {
      return rawHtml ?? "";
    }
  }

  // --- CARICAMENTO DATI PER 3 SETTIMANE ---
  Future<void> _caricaDatiMultiSettimana() async {
    try {
      StringBuffer htmlAccumulato = StringBuffer();
      int gareTrovateTotali = 0;

      // Ciclo per le prossime 3 settimane
      for (int i = 0; i < 3; i++) {
        DateTime lunedi = _getLunediSettimana(i);
        String dataUrl =
            "${lunedi.day.toString().padLeft(2, '0')}%2F${lunedi.month.toString().padLeft(2, '0')}%2F${lunedi.year}";
        String labelSettimana =
            "Settimana del ${lunedi.day}/${lunedi.month}/${lunedi.year}";

        // URL FIPAV con StatoGara=0 (Tutte le gare)
        String urlFipav =
            "https://www.fipavpd.net/risultati-classifiche.aspx?"
            "ComitatoId=3&"
            "StId=2265&"
            "DataDa=$dataUrl&"
            "StatoGara=0&" // <--- 0 = Tutte le gare (disputate e non)
            "CId=&"
            "SId=45&"
            "PId=16651&"
            "btFiltro=CERCA";

        final response = await http.get(Uri.parse(urlFipav));

        if (response.statusCode == 200) {
          var document = parser.parse(response.body);
          var tabelle = document.querySelectorAll('table');
          bool trovateInQuestaSettimana = false;
          StringBuffer htmlSettimana = StringBuffer();

          for (var tabella in tabelle) {
            if (tabella.innerHtml.contains("Gara") &&
                tabella.innerHtml.contains("Squadra")) {
              trovateInQuestaSettimana = true;
              gareTrovateTotali++;

              // Estrai Titolo Campionato
              String nomeCampionato = "";
              var caption = tabella.querySelector('caption');
              if (caption != null) {
                nomeCampionato = caption.text.trim();
                caption.remove();
              } else {
                nomeCampionato = "Campionato";
              }

              // Processa Righe (Mappe e Pulizia)
              var righe = tabella.querySelectorAll('tr');
              for (var riga in righe) {
                var immagini = riga.querySelectorAll('img');
                for (var img in immagini) {
                  String? rawInfo =
                      img.attributes['title'] ?? img.attributes['alt'];
                  if (rawInfo != null && rawInfo.isNotEmpty) {
                    String txtCheck = rawInfo.toLowerCase();
                    bool isStatoGara =
                        txtCheck.contains("gara") ||
                        txtCheck.contains("risultato") ||
                        txtCheck.contains("spostata") ||
                        txtCheck.contains("rinviata") ||
                        txtCheck.contains("sospesa") ||
                        txtCheck.contains("annullata") ||
                        txtCheck.contains("disputare") ||
                        txtCheck.contains("non disputata");

                    String infoPulita = _pulisciIndirizzoHtml(rawInfo);

                    if (isStatoGara) {
                      // Solo testo per lo stato (Gara da disputare, etc.)
                      var label = dom.Element.html(
                        '<div style="font-size:10px;color:#666;font-style:italic;">$infoPulita</div>',
                      );
                      img.replaceWith(label);
                    } else if (infoPulita.length > 5) {
                      // LINK MAPPE (Usa lo schema app:// per essere intercettato)
                      String fakeUrl =
                          "app://aprimappe?q=${Uri.encodeComponent(infoPulita)}";

                      var btnMap = dom.Element.html('''
                        <a href="$fakeUrl" style="text-decoration:none;display:block;margin-top:4px;">
                          <div style="background-color:#e3f2fd;color:#0055AA;border:1px solid #0055AA;border-radius:6px;padding:5px;font-size:11px;font-weight:bold;text-align:center;">
                            📍 NAVIGA<br><span style="font-weight:normal;font-size:10px;color:#333;">$infoPulita</span>
                          </div>
                        </a>''');
                      img.replaceWith(btnMap);
                    } else {
                      img.remove();
                    }
                  } else {
                    img.remove();
                  }
                }
              }

              // Aggiungi Titolo e Tabella
              htmlSettimana.write(
                '<h5 style="color:#d32f2f;margin:15px 0 5px 0;text-transform:uppercase;">$nomeCampionato</h5>',
              );
              htmlSettimana.write(
                '<div class="table-wrapper">${tabella.outerHtml}</div>',
              );
            }
          }

          if (trovateInQuestaSettimana) {
            htmlAccumulato.write('''
              <div class="settimana-block">
                <div class="settimana-header">$labelSettimana</div>
                ${htmlSettimana.toString()}
              </div>
            ''');
          }
        }
      }

      if (gareTrovateTotali == 0) {
        throw Exception("Nessuna gara trovata nelle prossime 3 settimane.");
      }

      // Costruzione HTML Finale
      String htmlFinale =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: 'Roboto', sans-serif; background-color: #FFFFFF; margin: 0; padding: 10px; padding-bottom: 50px; }
            
            h3.main-title { color: #0055AA; text-align: center; margin-bottom: 20px; }
            
            .settimana-block { margin-bottom: 30px; border-bottom: 4px solid #eee; padding-bottom: 20px; }
            
            .settimana-header { 
              background-color: #0055AA; 
              color: white; 
              padding: 8px 15px; 
              font-size: 14px; 
              font-weight: bold; 
              border-radius: 20px; 
              display: inline-block;
              margin-bottom: 10px;
            }

            h5 { font-size: 14px; letter-spacing: 0.5px; border-left: 4px solid #d32f2f; padding-left: 8px; }

            .table-wrapper { width: 100%; overflow-x: auto; margin-bottom: 10px; }
            
            table { width: 100%; border-collapse: collapse; min-width: 600px; font-size: 13px; }
            
            th { background-color: #f1f1f1; color: #333; padding: 8px; text-align: left; font-size: 11px; white-space: nowrap; }
            
            td { padding: 8px; border-bottom: 1px solid #eee; color: #333; vertical-align: middle; }
            
            tr:nth-child(even) { background-color: #f9f9f9; }
            
            td:contains("CADONEGHE"), td:contains("Cadoneghe") { font-weight: bold; color: #d32f2f; }

            /* NASCONDI COLONNE "Gara" e "G" (di solito le prime due) */
            th:nth-child(1), td:nth-child(1),
            th:nth-child(2), td:nth-child(2) { display: none; }
          </style>
        </head>
        <body>
          <h3 class="main-title">${widget.titoloPagina}</h3>
          
          ${htmlAccumulato.toString()}

          <div style="text-align: center; margin-top: 30px; color: #999; font-size: 11px;">
            Fonte: Fipav Padova - Prossime 3 Settimane<br>
            Codice Società: 45
          </div>
        </body>
        </html>
      ''';

      await _controller.loadHtmlString(
        htmlFinale,
        baseUrl: "https://www.fipavpd.net/",
      );

      if (mounted) {
        setState(() => _isLoading = false);
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
              _caricaDatiMultiSettimana();
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Nessuna gara trovata",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Non ci sono partite in programma nelle prossime 3 settimane.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _caricaDatiMultiSettimana();
                      },
                      child: const Text("Aggiorna"),
                    ),
                  ],
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
