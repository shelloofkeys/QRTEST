import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MaterialApp(home: QRToFileApp()));

class QRToFileApp extends StatefulWidget {
  const QRToFileApp({super.key});

  @override
  State<QRToFileApp> createState() => _QRToFileAppState();
}

class _QRToFileAppState extends State<QRToFileApp> {
  bool isProcessing = false;

  // Funzione che salva il testo nel file
  Future<void> _saveTextToFile(String text) async {
    try {
      // Trova la cartella documenti del dispositivo
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/testi_scansionati.txt');

      // Scrive il testo aggiungendolo alla fine (append) e aggiunge una riga vuota
      await file.writeAsString('$text\n---\n', mode: FileMode.append);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Salvato in: ${file.path}')),
      );
    } catch (e) {
      debugPrint("Errore salvataggio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner > Scrittore File")),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              if (isProcessing) return; // Evita scansioni multiple contemporanee

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => isProcessing = true);
                  
                  // Salva il testo contenuto nel QR
                  await _saveTextToFile(barcode.rawValue!);
                  
                  // Aspetta 2 secondi prima di permettere un'altra scansione
                  await Future.delayed(const Duration(seconds: 2));
                  setState(() => isProcessing = false);
                  break;
                }
              }
            },
          ),
          if (isProcessing)
            const Center(
              child: Card(
                color: Colors.black54,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Testo salvato!", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
