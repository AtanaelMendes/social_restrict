import 'package:flutter_screentime/models/token_id_model.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class QrRepository {
  final Api api = Api();
  final Logger _logger = Logger();

  Future<bool> tokenId(TokenIdModel tokenIdModel) async {
    _logger.i("Enviando TokenIdModel: ${tokenIdModel.toMap()}");

    try {
      Response? response = await api.postTokenId(tokenIdModel.toMap());

      _logger.i("Resposta recebida. Status: ${response?.statusCode}");
      _logger.d("Dados da resposta: ${response?.data}");

      if (response != null && response.statusCode == 200) {
        _logger.i("Token ID enviado com sucesso.");
        return true;
      } else {
        _logger.w("Falha ao enviar Token ID. Status: ${response?.statusCode}");
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e("Erro ao enviar Token ID", error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
