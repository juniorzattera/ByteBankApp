import 'dart:convert';
import 'package:bytebank/http/webclient.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:http/http.dart';

class TransactionWebClient {
  Future<List<Transaction>> findAll() async {
    final Response response = await client.get(baseUrl);
    final List<dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson
        .map((dynamic json) => Transaction.fromJson(json))
        .toList();
  }

  Future<Transaction> save(Transaction transaction, String password) async {
    final String transactionJson = jsonEncode(transaction.toJson());
    await Future.delayed(Duration(seconds: 2));
    final Response response = await client.post(baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'password': password,
        },
        body: transactionJson);

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    }

    throw HttpException(_getMessage(response.statusCode));
  }

  String _getMessage(int statusCode) {
    if (_statusCodeResponses.containsKey(statusCode)) {
      return _statusCodeResponses[statusCode];
    }
    return 'Unknown Error';
  }

  static final Map<int, String> _statusCodeResponses = {
    400: 'Ocorreu um Erro ao enviar a Transferencia....',
    401: 'Erro de Autenticação....',
    409: 'Essa Transaçao já foi Realizada...'
  };
}

class HttpException implements Exception {
  final String message;

  HttpException(this.message);
}
