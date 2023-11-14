import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class AppState with ChangeNotifier {
  List<String> codiciAutorizzati = [
    "ID001:Nome1:Cognome1",
    "ID002:Nome2:Cognome2",
    // Aggiungi altri codici autorizzati qui
  ];

  List<String> codiciLetti = [];

  void aggiungiCodiceLettura(String codice) {
    if (!codiciLetti.contains(codice)) {
      codiciLetti.add(codice);
      notifyListeners();
    }
  }

  bool codiceGiaLettura(String codice) {
    return codiciLetti.contains(codice);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        home: QRViewExample(),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: result != null
                  ? buildResult(context, result!)
                  : Text('Scansiona un QR Code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResult(BuildContext context, Barcode result) {
    final appState = Provider.of<AppState>(context, listen: false);

    if (appState.codiceGiaLettura(result.code)) {
      return Text('Codice già utilizzato');
    }

    appState.aggiungiCodiceLettura(result.code);

    final List<String> infoUtente = appState.codiciAutorizzati
        .firstWhere((codiceAutorizzato) => codiceAutorizzato.startsWith(result.code))
        .split(':')
        .sublist(1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Nome: ${infoUtente[0]}'),
        Text('Cognome: ${infoUtente[1]}'),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

