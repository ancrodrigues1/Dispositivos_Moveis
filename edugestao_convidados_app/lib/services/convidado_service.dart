import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/convidado.dart';

class ConvidadoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = "convidados";

  // 🎯 Estados de resposta (evita strings soltas no código)
  static const String statusOk = "OK";
  static const String statusJaEntrou = "JA_ENTROU";
  static const String statusNaoEncontrado = "NAO_ENCONTRADO";

  // 🔎 Buscar por NIF
  Future<Map<String, dynamic>?> buscarPorNifComId(String nif) async {
    try {
      final query = await _db
          .collection(_collection)
          .where("nif", isEqualTo: nif)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;

      return {
        "id": doc.id,
        "data": doc.data(),
      };
    } catch (e) {
      throw Exception("Erro ao buscar por NIF: $e");
    }
  }

  // 📥 Buscar por ID (QR Code)
  Future<Map<String, dynamic>?> buscarPorId(String id) async {
    try {
      final query = await _db
          .collection(_collection)
          .where("id", isEqualTo: id)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;

      return doc.data();;
    } catch (e) {
      throw Exception("Erro ao buscar por ID: $e");
    }
  }

  // 📋 Buscar todos
  Future<List<Map<String, dynamic>>> buscarTodosComId() async {
    try {
      final query = await _db.collection(_collection).get();

      return query.docs.map((doc) {
        return {
          "id": doc.id,
          "data": doc.data(),
        };
      }).toList();
    } catch (e) {
      throw Exception("Erro ao buscar convidados: $e");
    }
  }

  // ✅ 🚀 Check-in seguro com TRANSAÇÃO
  Future<String> fazerCheckin(String id) async {
    try {
      return await _db.runTransaction((transaction) async {
        final ref = _db.collection(_collection).doc(id);
        final snapshot = await transaction.get(ref);

        // ❌ Não encontrado
        if (!snapshot.exists) {
          return statusNaoEncontrado;
        }

        final data = snapshot.data();

        // ⚠️ Já entrou
        if (data?["compareceu"] == true) {
          return statusJaEntrou;
        }

        return statusOk;
      });
    } catch (e) {
      throw Exception("Erro no check-in: $e");
    }
  }

  // 🚫 Verificar se já compareceu (sem transação)
  Future<bool> jaCompareceu(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();

      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      return data["compareceu"] == true;
    } catch (e) {
      throw Exception("Erro ao verificar presença: $e");
    }
  }

  Future<void> confirmarPresenca(String id) async {
    await _db.collection(_collection).doc(id).update({
      "compareceu": true,
    });
  }

  // 🧑‍💼 (Opcional) Converter para Model
  Convidado? mapToConvidado(DocumentSnapshot doc) {
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    return Convidado.fromMap(data);
  }
}