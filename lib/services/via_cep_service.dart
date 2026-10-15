import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/endereco.dart';

/// Erro de consulta com mensagem pronta para exibir ao usuário.
class CepException implements Exception {
  final String mensagem;

  const CepException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Consulta CEPs no webservice do ViaCEP:
/// https://viacep.com.br/ws/{cep}/{formato}/
class ViaCepService {
  static const _baseUrl = 'https://viacep.com.br/ws';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  ViaCepService({http.Client? client}) : _client = client ?? http.Client();

  /// Remove tudo que não for dígito (aceita "01001-000" ou "01001000").
  static String limparCep(String cep) => cep.replaceAll(RegExp(r'\D'), '');

  /// O CEP precisa ter exatamente 8 dígitos.
  static bool cepValido(String cep) => limparCep(cep).length == 8;

  /// Busca o endereço do CEP. Lança [CepException] com a mensagem de erro.
  Future<Endereco> buscarCep(String cep) async {
    final digitos = limparCep(cep);
    if (digitos.length != 8) {
      throw const CepException('Digite um CEP válido com 8 dígitos!');
    }

    final url = Uri.parse('$_baseUrl/$digitos/json/');

    final http.Response response;
    try {
      response = await _client.get(url).timeout(_timeout);
    } on TimeoutException {
      throw const CepException('Tempo esgotado. Tente novamente.');
    } catch (_) {
      throw const CepException('Falha de conexão. Verifique sua internet.');
    }

    // O ViaCEP responde 400 quando o formato do CEP é inválido.
    if (response.statusCode == 400) {
      throw const CepException('CEP inválido!');
    }
    if (response.statusCode != 200) {
      throw CepException('Erro no servidor (${response.statusCode}).');
    }

    final dados = jsonDecode(utf8.decode(response.bodyBytes));

    // CEP com formato válido mas inexistente retorna 200 com {"erro": "true"}.
    if (dados is! Map<String, dynamic> || dados.containsKey('erro')) {
      throw const CepException('CEP não encontrado!');
    }

    return Endereco.fromJson(dados);
  }
}
