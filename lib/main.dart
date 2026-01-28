import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// --- PALETTE COLORI MODERNA ---
class CVColors {
  static const Color primaryDark = Color(0xFF004080); // Blu scuro dal logo
  static const Color primaryLight = Color(
    0xFF00A0E3,
  ); // Azzurro brillante dal logo
  static const Color accentOrange = Color(
    0xFFFF6B00,
  ); // Arancione sportivo vivace
  static const Color background = Color(
    0xFFF4F7F9,
  ); // Grigio chiarissimo freddo
  static const Color textDark = Color(0xFF0A1E3C); // Quasi nero, più morbido
  static const Color textLightGrey = Color(0xFF8A95A5);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadoneghe Volley',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Definizione dei colori principali
        colorScheme: ColorScheme.fromSeed(
          seedColor: CVColors.primaryDark,
          primary: CVColors.primaryDark,
          secondary: CVColors.primaryLight,
          tertiary: CVColors.accentOrange,
          background: CVColors.background,
        ),
        scaffoldBackgroundColor: CVColors.background,
        // Stile AppBar moderno
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800, // Molto bold
            letterSpacing: 0.5,
          ),
        ),
        // Stile Testi globale
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: CVColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 32,
            letterSpacing: -1.0,
          ),
          headlineMedium: TextStyle(
            color: CVColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
          titleLarge: TextStyle(
            color: CVColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(color: CVColors.textDark, fontSize: 16),
          bodyMedium: TextStyle(color: CVColors.textDark, fontSize: 14),
        ),
        // Stile Bottoni moderni e arrotondati
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: CVColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: CVColors.primaryDark.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Molto arrotondato
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        // Stile Card moderno
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
