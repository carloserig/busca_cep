import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/endereco.dart';
import '../services/via_cep_service.dart';
import '../utils/cep_input_formatter.dart';

class ConsultaCepPage extends StatefulWidget {
  const ConsultaCepPage({super.key, ViaCepService? service})
    : _service = service;

  final ViaCepService? _service;

  @override
  State<ConsultaCepPage> createState() => _ConsultaCepPageState();
}

class _ConsultaCepPageState extends State<ConsultaCepPage> {
  final _cepController = TextEditingController();
  late final ViaCepService _service = widget._service ?? ViaCepService();

  Endereco? _resultado;
  String _mensagem = '';
  bool _carregando = false;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> pesquisarCep() async {
    FocusScope.of(context).unfocus();

    if (!ViaCepService.cepValido(_cepController.text)) {
      setState(() {
        _resultado = null;
        _mensagem = 'Digite um CEP válido com 8 dígitos!';
      });
      return;
    }

    setState(() {
      _carregando = true;
      _mensagem = '';
      _resultado = null;
    });

    try {
      final dados = await _service.buscarCep(_cepController.text);
      if (!mounted) return;
      setState(() {
        _resultado = dados;
        _mensagem = '';
      });
    } on CepException catch (e) {
      if (!mounted) return;
      setState(() => _mensagem = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CEP'),
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CepInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Digite o CEP (8 dígitos)',
                hintText: '00000-000',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => pesquisarCep(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _carregando ? null : pesquisarCep,
              icon: _carregando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: const Text('Pesquisar'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),
            if (_mensagem.isNotEmpty) _MensagemErro(_mensagem),
            if (_resultado != null) _ResultadoCard(_resultado!),
          ],
        ),
      ),
    );
  }
}

class _MensagemErro extends StatelessWidget {
  const _MensagemErro(this.mensagem);

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Card(
      color: cores.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: cores.onErrorContainer),
        title: Text(mensagem, style: TextStyle(color: cores.onErrorContainer)),
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  const _ResultadoCard(this.endereco);

  final Endereco endereco;

  @override
  Widget build(BuildContext context) {
    final logradouro = [
      endereco.logradouro,
      endereco.complemento,
    ].where((s) => s.isNotEmpty).join(' - ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Endereço encontrado!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _Campo('Logradouro/Nome', logradouro),
            _Campo('Bairro/Distrito', endereco.bairro),
            _Campo('Cidade', endereco.localidade),
            _Campo('UF', endereco.uf),
            _Campo('CEP', endereco.cep),
            _Campo('DDD', endereco.ddd),
            _Campo('IBGE', endereco.ibge),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo(this.rotulo, this.valor);

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    // CEPs de localidade (cidades pequenas) vêm sem logradouro/bairro.
    if (valor.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$rotulo:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor),
        ],
      ),
    );
  }
}
