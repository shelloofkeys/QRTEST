import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const LyricsApp());
}

class LyricsApp extends StatelessWidget {
  const LyricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Lyrics Scanner',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // Database locale di prova
  final Map<String, String> lyricsDatabase = {
    "Albachiara": "Respiri piano per non far rumore...\nTi addormenti di sera...\nE ti risvegli col sole...",
    "Bohemian Rhapsody": "Is this the real life?\nIs this just fantasy?\nCaught in a landslide...",
  };

  bool isScanning = true;

  void _showLyrics(String content) {
    setState(() => isScanning = false);

    // Cerca se il contenuto del QR è un titolo nel database, 
    // altrimenti mostra il contenuto testuale del QR stesso.
    String textToShow = lyricsDatabase[content] ?? content;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(content, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(textToShow, style: const TextStyle(fontSize: 18)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => isScanning = true);
              },
              child: const Text("Chiudi e Scansiona ancora"),
            )
          ],
        ),
      ),
    ).then((_) => setState(() => isScanning = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scansiona QR Canzone")),
      body: isScanning
          ? MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _showLyrics(barcode.rawValue!);
                    break;
                  }
                }
              },
            )
          : const Center(child: Text("Elaborazione testo...")),
    );
  }
}
