class Convidado {
  String nome;
  String apelido;
  String nif;
  String email;
  String sala;
  String itinerario;
  final bool compareceu;

  Convidado({
    required this.nome,
    required this.apelido,
    required this.nif,
    required this.email,
    required this.sala,
    required this.itinerario,
    this.compareceu = false,
  });

  Map<String, dynamic> toJson() => {
        "nome": nome,
        "apelido": apelido,
        "nif": nif,
        "email": email,
        "sala": sala,
        "itinerario": itinerario,
        'compareceu': compareceu, 
      };

  factory Convidado.fromMap(Map<String, dynamic> map) {
    return Convidado(
      nome: map["nome"] ?? "",
      apelido: map["apelido"] ?? "",
      nif: map["nif"] ?? "",
      email: map["email"] ?? "",
      sala: map["sala"] ?? "",
      itinerario: map["itinerario"] ?? "",
    );
  }
    
}