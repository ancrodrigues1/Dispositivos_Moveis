import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/convidado.dart';
import '../screens/sucesso.dart';
import '../services/pdf_service.dart';

class CadastrarScreen extends StatefulWidget {
  @override
  _CadastrarScreenState createState() => _CadastrarScreenState();
}

class _CadastrarScreenState extends State<CadastrarScreen> {

  final _formKey = GlobalKey<FormState>();

  final nome = TextEditingController();
  final apelido = TextEditingController();
  final nif = TextEditingController();
  final email = TextEditingController();
  final sala = TextEditingController();

  final List<String> itinerarios = [
    "Kinder - Nível 1",
    "Kinder - Nível 2",
    "Kinder - Nível 3",
    "Tiny Tots - Nível 1",
    "Tiny Tots - Nível 2",
    "Tiny Tots - Nível 3",
    "Tiny Tots - Nível 4",
    "Tiny Tots - Nível 5",
    "Tiny Tots - Nível 6",
    "Tiny Tots - Nível 7",
    "Tiny Tots - Nível 8",
    "Tiny Tots - Nível 9",
    "Tiny Tots - Nível 10",
    "Kids - Nível 1",
    "Kids - Nível 2",
    "Kids - Nível 3",
    "Kids - Nível 4",
    "Kids - Nível 5",
    "Kids - Nível 6",
    "Kids - Nível 7",
    "Kids - Nível 8",
  ];

  String? itinerarioSelecionado;
  bool isLoading = false;

  @override
  void dispose() {
    nome.dispose();
    apelido.dispose();
    nif.dispose();
    email.dispose();
    sala.dispose();
    super.dispose();
  }

  void salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 🔍 Verificar NIF duplicado
      final query = await FirebaseFirestore.instance
          .collection('convidados')
          .where('nif', isEqualTo: nif.text)
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("NIF já registado!")),
        );
        setState(() => isLoading = false);
        return;
      }

      // 👤 Criar convidado
      final convidado = Convidado(
        nome: nome.text.trim(),
        apelido: apelido.text.trim(),
        nif: nif.text.trim(),
        email: email.text.trim(),
        sala: sala.text.trim(),
        itinerario: itinerarioSelecionado ?? "",
        compareceu: false,
      );

      // 🔥 Guardar no Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('convidados')
          .add(convidado.toJson());

      final firebaseId = docRef.id;

      // ✅ Guardar ID dentro do documento
      await FirebaseFirestore.instance
          .collection('convidados')
          .doc(firebaseId)
          .update({'id': firebaseId});

      // 📄 Gerar PDF com QR (ID)
      await PdfService.gerarPdf(convidado, firebaseId);

      setState(() => isLoading = false);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SucessoScreen(convidado: convidado),
        ),
      );

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar Convidado"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(Icons.person_add, size: 50, color: Colors.blue),
                    SizedBox(height: 10),

                    Text(
                      "Novo Convidado",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    _input(nome, "Nome", Icons.person),
                    _input(apelido, "Apelido", Icons.person_outline),
                    _input(nif, "NIF", Icons.badge),
                    _input(email, "Email", Icons.email),
                    _input(sala, "Sala", Icons.meeting_room),

                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        value: itinerarioSelecionado,
                        decoration: InputDecoration(
                          labelText: "Itinerário",
                          prefixIcon: Icon(Icons.map),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: itinerarios.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            itinerarioSelecionado = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Campo obrigatório" : null,
                      ),
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : salvar,
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text("Salvar"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value!.isEmpty ? "Campo obrigatório" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}