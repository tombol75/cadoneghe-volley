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
            if (request.url.startsWith("app://aprimappe")) {
              final Uri uri = Uri.parse(request.url);
              final String? queryAddress = uri.queryParameters['q'];

              if (queryAddress != null && queryAddress.isNotEmpty) {
                final Uri mapsUrl = Uri.parse(
                  "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(queryAddress)}",
                );

                try {
                  if (await canLaunchUrl(mapsUrl)) {
                    await launchUrl(
                      mapsUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    await launchUrl(mapsUrl);
                  }
                } catch (e) {
                  debugPrint("Impossibile aprire mappa: $e");
                }
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _caricaDatiFipav();
  }

  String _calcolaDataLunediCorrente() {
    DateTime now = DateTime.now();
    int giorniDaSottrarre = now.weekday - 1;
    DateTime lunedi = now.subtract(Duration(days: giorniDaSottrarre));

    String giorno = lunedi.day.toString().padLeft(2, '0');
    String mese = lunedi.month.toString().padLeft(2, '0');
    String anno = lunedi.year.toString();

    return "$giorno/$mese/$anno";
  }

  String _pulisciIndirizzoHtml(String? rawHtml) {
    if (rawHtml == null || rawHtml.isEmpty) return "";

    try {
      var fragment = parser.parseFragment(rawHtml);

      fragment.querySelectorAll('.designazione').forEach((e) => e.remove());

      fragment.querySelectorAll('*').forEach((e) {
        String testoElem = (e.text ?? "").toLowerCase();
        if (testoElem.contains('arbitro') || testoElem.contains('designato')) {
          e.remove();
        }
      });

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

  Future<void> _caricaDatiFipav() async {
    try {
      String dataLunedi = _calcolaDataLunediCorrente();
      String dataEncoded = dataLunedi.replaceAll('/', '%2F');

      String urlFipav =
          "https://www.fipavpd.net/risultati-classifiche.aspx?"
          "ComitatoId=3&"
          "StId=2265&"
          "DataDa=$dataEncoded&"
          "StatoGara=0&"
          "CId=&"
          "SId=45&"
          "PId=16651&"
          "btFiltro=CERCA";

      final response = await http.get(Uri.parse(urlFipav));

      if (response.statusCode != 200) {
        throw Exception("Errore server FIPAV: ${response.statusCode}");
      }

      var document = parser.parse(response.body);
      var tabelle = document.querySelectorAll('table');

      StringBuffer htmlContenutoGare = StringBuffer();
      int tabelleTrovate = 0;

      for (var tabella in tabelle) {
        if (tabella.innerHtml.contains("Gara") &&
            tabella.innerHtml.contains("Squadra")) {
          tabelleTrovate++;

          String nomeCampionato = "";
          var caption = tabella.querySelector('caption');
          if (caption != null) {
            nomeCampionato = caption.text.trim();
            caption.remove();
          } else {
            nomeCampionato = "Campionato";
          }

          var righe = tabella.querySelectorAll('tr');
          for (var riga in righe) {
            var immagini = riga.querySelectorAll('img');

            for (var img in immagini) {
              String? rawInfo = img.attributes['title'];
              if (rawInfo == null || rawInfo.isEmpty) {
                rawInfo = img.attributes['alt'];
              }

              if (rawInfo != null && rawInfo.isNotEmpty) {
                // --- FILTRO POTENZIATO ---
                String txtCheck = rawInfo.toLowerCase();

                bool isStatoGara =
                    txtCheck.contains("gara") ||
                    txtCheck.contains("risultato") ||
                    txtCheck.contains("spostata") ||
                    txtCheck.contains("rinviata") ||
                    txtCheck.contains("disputare") || // <--- AGGIUNTO
                    txtCheck.contains("sospesa") || // <--- AGGIUNTO
                    txtCheck.contains("annullata") || // <--- AGGIUNTO
                    txtCheck.contains("non disputata");

                String infoPulita = _pulisciIndirizzoHtml(rawInfo);

                if (isStatoGara) {
                  // STATO GARA -> Solo testo semplice
                  var labelStato = dom.Element.html(
                    '''<div style="font-size: 10px; color: #666; font-style: italic; white-space: nowrap;">$infoPulita</div>''',
                  );
                  img.replaceWith(labelStato);
                } else if (infoPulita.length > 5) {
                  // INDIRIZZO -> Link Mappe
                  String fakeUrl =
                      "app://aprimappe?q=${Uri.encodeComponent(infoPulita)}";

                  var linkMaps = dom.Element.html('''
                    <a href="$fakeUrl" style="text-decoration: none; display: block; margin-top: 4px;">
                      <div style="
                        background-color: #e3f2fd; 
                        color: #0055AA; 
                        border: 1px solid #0055AA;
                        border-radius: 6px; 
                        padding: 6px; 
                        font-size: 11px; 
                        font-weight: bold;
                        text-align: center;
                        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                      ">
                        📍 NAVIGA
                        <div style="font-weight: normal; font-size: 10px; margin-top: 2px; color: #333;">$infoPulita</div>
                      </div>
                    </a>
                    ''');
                  img.replaceWith(linkMaps);
                } else {
                  // Se troppo corto o ignoto, rimuoviamo
                  img.remove();
                }
              } else {
                img.remove();
              }
            }
          }

          if (nomeCampionato.isNotEmpty) {
            htmlContenutoGare.write(
              '<h4 style="color: #d32f2f; margin-top: 30px; margin-bottom: 10px; border-bottom: 2px solid #eee; padding-bottom: 5px;">$nomeCampionato</h4>',
            );
          }

          htmlContenutoGare.write('<div class="table-wrapper">');
          htmlContenutoGare.write(tabella.outerHtml);
          htmlContenutoGare.write('</div>');
        }
      }

      if (tabelleTrovate == 0) {
        throw Exception("Nessuna gara trovata per questa settimana.");
      }

      String htmlFinale =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { 
              font-family: 'Roboto', sans-serif; 
              background-color: #FFFFFF; 
              margin: 0; 
              padding: 15px; 
              padding-bottom: 50px;
            }
            h3.main-title { color: #0055AA; text-align: center; margin-bottom: 10px; }
            h4 { font-size: 16px; text-transform: uppercase; letter-spacing: 0.5px; }
            .table-wrapper {
              width: 100%;
              overflow-x: auto;
              box-shadow: 0 2px 5px rgba(0,0,0,0.05);
              border-radius: 8px;
              margin-bottom: 20px;
              border: 1px solid #eee;
            }
            table { 
              width: 100%; 
              border-collapse: collapse; 
              min-width: 600px; 
              font-size: 13px;
            }
            th {
              background-color: #0055AA;
              color: white;
              padding: 10px;
              text-align: left;
              white-space: nowrap;
              font-size: 12px;
            }
            td { 
              padding: 10px; 
              border-bottom: 1px solid #eee;
              color: #333;
              vertical-align: middle;
            }
            tr:nth-child(even) { background-color: #f9f9f9; }
            td:contains("CADONEGHE"), td:contains("Cadoneghe") {
              font-weight: bold;
              color: #d32f2f;
            }
          </style>
        </head>
        <body>
          <h3 class="main-title">${widget.titoloPagina}</h3>
          ${htmlContenutoGare.toString()}
          <div style="text-align: center; margin-top: 30px; color: #999; font-size: 11px;">
            Fonte: Fipav Padova (Settimana del $dataLunedi)<br>
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
              _caricaDatiFipav();
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
                      "Nessuna gara in programma",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Non ci sono partite previste per questa settimana\no impossibile recuperare i dati.",
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
                        _caricaDatiFipav();
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
