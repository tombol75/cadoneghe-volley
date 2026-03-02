import 'package:flutter/material.dart';
import 'sport_colors.dart';

class ContattiPage extends StatelessWidget {
  const ContattiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatti'),
        backgroundColor: SportColors.blueDeep,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 80,
                color: SportColors.blueDeep,
              ),
              const SizedBox(height: 30),
              const Text(
                "A.S.D. Polisportiva Cadoneghe",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: SportColors.blueDeep,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "P.zza San Bonaventura, 1\n35010 CADONEGHE (PD)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: SportColors.textDark,
                ),
              ),
              const SizedBox(height: 30),
              const Divider(indent: 40, endIndent: 40),
              const SizedBox(height: 30),
              const Text(
                "Email Ufficiale:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "info@pallavolocadoneghe.it",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
