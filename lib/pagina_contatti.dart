import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaginaContatti extends StatefulWidget {
  const PaginaContatti({super.key});

  @override
  State<PaginaContatti> createState() => _PaginaContattiState();
}

class _PaginaContattiState extends State<PaginaContatti> {
  final _formKey = GlobalKey<FormState>();

  // Controller per i campi di testo
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController(); // Opzionale
  final _messaggioController = TextEditingController();

  Future<void> _inviaEmail() async {
    if (_formKey.currentState!.validate()) {
      final String nome = _nomeController.text;
      final String cognome = _cognomeController.text;
      final String email = _emailController.text;
      final String telefono = _telefonoController.text;
      final String messaggio = _messaggioController.text;

      final String corpoMail =
          "Nuova segnalazione:\n\nNome: $nome $cognome\nEmail: $email\nTelefono: $telefono\n\nMessaggio:\n$messaggio";

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'tuaemail@esempio.com', // <--- CAMBIA QUESTO
        query: encodeQueryParameters({
          'subject': 'Contatto App Volley',
          'body': corpoMail,
        }),
      );

      try {
        await launchUrl(emailLaunchUri);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile aprire email')),
        );
      }
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Permette allo sfondo di andare dietro la barra in alto
      appBar: AppBar(
        title: const Text("Contattaci"),
        backgroundColor: Colors.transparent, // Barra trasparente
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. SFONDO IMMAGINE
          Positioned.fill(
            child: Image.asset('assets/banner_volley.png', fit: BoxFit.cover),
          ),
          // 2. MODULO
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.white.withOpacity(0.95),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _campoTesto(_nomeController, 'Nome *', true),
                          const SizedBox(height: 10),
                          _campoTesto(_cognomeController, 'Cognome *', true),
                          const SizedBox(height: 10),
                          _campoTesto(
                            _emailController,
                            'Email *',
                            true,
                            tipo: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          _campoTesto(
                            _telefonoController,
                            'Telefono (Opzionale)',
                            false,
                            tipo: TextInputType.phone,
                          ),
                          const SizedBox(height: 10),
                          _campoTesto(
                            _messaggioController,
                            'Messaggio *',
                            true,
                            linee: 4,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _inviaEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0055AA),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'INVIA',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoTesto(
    TextEditingController ctrl,
    String label,
    bool obbligatorio, {
    TextInputType? tipo,
    int linee = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      maxLines: linee,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) => obbligatorio && (v == null || v.isEmpty)
          ? 'Campo obbligatorio'
          : null,
    );
  }
}
