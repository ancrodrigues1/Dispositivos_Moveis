import 'package:flutter/material.dart';
import 'cadastrar.dart';
import 'scanner.dart';
import 'gerar_convite.dart';

class MenuScreen extends StatelessWidget {
  final String nome;

  const MenuScreen({Key? key, required this.nome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EduGestão Convidados"),
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
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, size: 60, color: Colors.blue),
                  SizedBox(height: 10),

                  Text(
                    "Bem-vindo, $nome 👋",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 25),
                  
                  if (nome=="administrador")...[
                    _menuButton(
                      context,
                      icon: Icons.person_add,
                      title: "Criar Convidado",
                      subtitle: "Registrar novo visitante",
                      screen: CadastrarScreen(),
                    ),
                  
                    SizedBox(height: 15),

                    _menuButton(
                      context,
                      icon: Icons.card_giftcard,
                      title: "Gerar Convites",
                      subtitle: "Gerar convites de convidados já cadastrados.",
                      screen: GerarConviteScreen(),
                    ),

                    SizedBox(height: 15),
                  ],
                  _menuButton(
                    context,
                    icon: Icons.qr_code_scanner,
                    title: "Registrar Presença",
                    subtitle: "Ler QR Code",
                    screen: ScannerPage(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Widget screen}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16)
            ],
          ),
        ),
      ),
    );
  }
}