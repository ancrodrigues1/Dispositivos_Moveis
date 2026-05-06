import 'dart:convert';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/convidado.dart';

class PdfService {
  static Future<void> gerarPdf(
    Convidado c,
    String firebaseId, {
    String dataEvento = "23 de maio de 2026",
    String localEvento = "Universidade da Maia",
  }) async {
    final pdf = pw.Document();

    final qrData = jsonEncode({
      "id": firebaseId,
      "nome": "${c.nome} ${c.apelido}",
      "evento": "aloha",
      "tipo": "bilhete",
    });

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [

                // HEADER
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "BILHETE DE ENTRADA",
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "EVENTO ALOHA",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 15),

                // DADOS
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Nome: ${c.nome} ${c.apelido}"),
                    pw.Text("NIF: ${c.nif}"),
                    pw.Text("Email: ${c.email}"),
                    pw.Text("Sala: ${c.sala}"),
                    pw.Text("Itinerário: ${c.itinerario}"),
                    pw.Text("Data do evento: $dataEvento"),
                    pw.Text("Local: $localEvento"),
                  ],
                ),

                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),

                // QR CODE
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          "APRESENTE ESTE QR CODE",
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 10),

                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                          width: 140,
                          height: 140,
                        ),

                        pw.SizedBox(height: 10),

                        pw.Text(
                          "ID: $firebaseId",
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // FOOTER
                pw.Center(
                  child: pw.Text(
                    "Entrada válida apenas com QR Code",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();

    // 📤 Partilhar / guardar PDF
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'bilhete_${firebaseId}.pdf',
    );
  }
}