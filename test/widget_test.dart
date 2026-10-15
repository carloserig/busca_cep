import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:busca_cep/pages/consulta_cep_page.dart';
import 'package:busca_cep/services/via_cep_service.dart';

const _jsonSe =
    '{"cep":"01001-000","logradouro":"Praça da Sé",'
    '"complemento":"","bairro":"Sé","localidade":"São Paulo","uf":"SP",'
    '"ibge":"3550308","ddd":"11"}';

ViaCepService _service(String body, [int status = 200]) => ViaCepService(
  client: MockClient(
    (_) async => http.Response.bytes(utf8.encode(body), status),
  ),
);

Future<void> _pesquisar(
  WidgetTester tester,
  ViaCepService service,
  String cep,
) async {
  await tester.pumpWidget(MaterialApp(home: ConsultaCepPage(service: service)));
  await tester.enterText(find.byType(TextField), cep);
  await tester.tap(find.text('Pesquisar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('exibe o endereço encontrado', (tester) async {
    await _pesquisar(tester, _service(_jsonSe), '01001000');

    expect(find.text('01001-000'), findsWidgets);
    expect(find.text('Endereço encontrado!'), findsOneWidget);
    expect(find.text('Praça da Sé'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);
  });

  testWidgets('trata {"erro": "true"} como CEP não encontrado', (tester) async {
    await _pesquisar(tester, _service('{"erro": "true"}'), '99999999');
    expect(find.text('CEP não encontrado!'), findsOneWidget);
  });

  testWidgets('valida CEP com menos de 8 dígitos', (tester) async {
    await _pesquisar(tester, _service(_jsonSe), '0100');
    expect(find.text('Digite um CEP válido com 8 dígitos!'), findsOneWidget);
  });
}
