import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/convidado_service.dart';
import 'dart:convert';
import '../screens/detalhe_convidado_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ConvidadoService _service = ConvidadoService();

  bool _isProcessing = false;
  DateTime? _lastScan;

  String? _mensagem;
  Color _corMensagem = Colors.transparent;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final now = DateTime.now();

    if (_lastScan != null &&
        now.difference(_lastScan!) < const Duration(seconds: 2)) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) return;

      final decoded = jsonDecode(raw!);
      final id = decoded["id"];

      if (id == null) continue;

      setState(() {
        _isProcessing = true;
        _mensagem = "A validar...";
        _corMensagem = Colors.blue;
      });

      _lastScan = now;

      try {
        final resultado = await _service.fazerCheckin(id);

        if (!mounted) return;

        switch (resultado) {
          case "OK":
            _mostrarFeedback("Entrada autorizada", Colors.green);
            final resultadofinal = await _service.buscarPorId(id);
            if (resultadofinal == null) {
              _mostrarFeedback("Convidado não encontrado", Colors.red);
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalheConvidadoPage(dados: resultadofinal),
              ),
            );
            break;

          case "JA_ENTROU":
            _mostrarFeedback("Já fez check-in", Colors.orange);
            break;

          case "NAO_ENCONTRADO":
            _mostrarFeedback("QR inválido", Colors.red);
            break;
        }
      } catch (e) {
        if (!mounted) return;
        _mostrarFeedback("Erro ao validar", Colors.red);
      }

      break;
    }
  }

  void _mostrarFeedback(String mensagem, Color cor) {
    setState(() {
      _mensagem = mensagem;
      _corMensagem = cor;
      _isProcessing = false;
    });

    // limpa mensagem depois de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _mensagem = null;
        _corMensagem = Colors.transparent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check-in QR Code")),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),

          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),

          if (_mensagem != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: _corMensagem,
                child: Text(
                  _mensagem!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}