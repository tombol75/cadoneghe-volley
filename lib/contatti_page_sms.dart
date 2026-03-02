import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContattiPage extends StatefulWidget {
  const ContattiPage({super.key});

  @override
  State<ContattiPage> createState() => _ContattiPageState();
}

class _ContattiPageState extends State<ContattiPage> {
  final _nomeController = TextEditingController();
  final _argomentoController = TextEditingController();
  final _messaggioController = TextEditingController();

  String? _numeroDestinatario;
  bool _isLoadingNumero = true;

  @override
  void initState() {
    super.initState();
    _caricaNumeroDaDB();
  }

  Future<void> _caricaNumeroDaDB() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('impostazioni')
          .doc('contatti')
          .get();

      if (doc.exists && doc.data() != null) {
        if (mounted) {
          setState(() {
            // --- LA CORREZIONE È QUI ---
            // Aggiungiamo .toString() alla fine.
            // Così se Firebase restituisce un numero (int), noi lo convertiamo in testo (String)
            _numeroDestinatario = doc.data()!['numero'].toString();
            _isLoadingNumero = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingNumero = false);
      }
    } catch (e) {
      debugPrint("Errore caricamento numero: $e");
      if (mounted) setState(() => _isLoadingNumero = false);
    }
  }

  Future<void> _inviaSMS() async {
    if (_numeroDestinatario == null || _numeroDestinatario!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Errore: Numero società non configurato."),
        ),
      );
      return;
    }

    if (_nomeController.text.isEmpty || _messaggioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci almeno Nome e Messaggio.")),
      );
      return;
    }

    final corpoMessaggio =
        "SEGNALAZIONE DA APP\n\n"
        "NOME: ${_nomeController.text}\n"
        "ARGOMENTO: ${_argomentoController.text}\n"
        "--------------------\n"
        "${_messaggioController.text}";

    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: _numeroDestinatario,
      queryParameters: <String, String>{'body': corpoMessaggio},
    );

    try {
      if (await canLaunchUrl(smsLaunchUri)) {
        await launchUrl(smsLaunchUri);
      } else {
        await launchUrl(smsLaunchUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Impossibile aprire SMS: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatti & Segnalazioni'),
        backgroundColor: const Color.fromARGB(255, 64, 116, 188),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingNumero
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.sms_outlined,
                    size: 60,
                    color: Color.fromARGB(255, 64, 116, 188),
                  ),
                  const SizedBox(height: 10),

                  if (_numeroDestinatario == null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.red.shade100,
                      child: const Text(
                        "ATTENZIONE: Numero non configurato. Vai in Admin > Impostazioni.",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    const Text(
                      "Inviaci una segnalazione via SMS.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: "Il tuo Nome",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _argomentoController,
                    decoration: const InputDecoration(
                      labelText: "Argomento",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _messaggioController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "Messaggio...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _numeroDestinatario != null ? _inviaSMS : null,
                    icon: const Icon(Icons.send),
                    label: const Text("INVIA SMS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 64, 116, 188),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
