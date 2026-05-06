import 'package:flutter/material.dart';
import '../models/convidado.dart';
import '../services/convidado_service.dart';
import '../services/pdf_service.dart';

class GerarConviteScreen extends StatefulWidget {
  const GerarConviteScreen({super.key});

  @override
  State<GerarConviteScreen> createState() => _GerarConviteScreenState();
}

class _GerarConviteScreenState extends State<GerarConviteScreen> {
  final TextEditingController nifController = TextEditingController();
  final service = ConvidadoService();

  bool loading = false;

  Future<void> gerarPorNif() async {
    setState(() => loading = true);

    final nif = nifController.text.trim(); 

    final result = await service.buscarPorNifComId(nif);

    if (result == null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Convidado não encontrado")),
      );
      return;
    }

    final id = result["id"];
    final convidado = Convidado.fromMap(result["data"]);

    await PdfService.gerarPdf(convidado, id);

    setState(() => loading = false);
  }

  Future<void> gerarTodos() async {
    setState(() => loading = true);

    final lista = await service.buscarTodosComId();

    for (var item in lista) {
      final id = item["id"];
      final data = item["data"];

      final convidado = Convidado.fromMap(data);

      await PdfService.gerarPdf(convidado, id);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerar Convites"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nifController,
              decoration: InputDecoration(
                labelText: "NIF do convidado",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loading ? null : gerarPorNif,
              icon: Icon(Icons.search),
              label: Text("Gerar convite por NIF"),
            ),

            SizedBox(height: 20),

            Divider(),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loading ? null : gerarTodos,
              icon: Icon(Icons.group),
              label: Text("Gerar todos os convites"),
            ),

            if (loading) ...[
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ]
          ],
        ),
      ),
    );
  }
}