import 'package:flutter_screentime/models/token_id_model.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:dio/dio.dart';

class QrRepository {
  Api api = Api();

  Future<bool> tokenId(TokenIdModel tokenIdModel) async {
    Response? response = await api.postTokenId(tokenIdModel.toMap());

    if (response != null && response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
