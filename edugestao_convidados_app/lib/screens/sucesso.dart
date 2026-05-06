import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/convidado.dart';
import '../services/pdf_service.dart';

class SucessoScreen extends StatelessWidget {
  final Convidado convidado;

  const SucessoScreen({super.key, required this.convidado});

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode(convidado.toJson());

    return Scaffold(
      appBar: AppBar(title: Text("Sucesso")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Convidado criado com sucesso!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            QrImageView(
              data: qrData,
              size: 180,
            ),
          ],
        ),
      ),
    );
  }
}