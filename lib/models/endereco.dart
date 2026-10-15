/// Endereço retornado pelo webservice do ViaCEP.
class Endereco {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;
  final String estado;
  final String ibge;
  final String ddd;

  const Endereco({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.estado,
    required this.ibge,
    required this.ddd,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    String campo(String chave) => (json[chave] ?? '').toString();

    return Endereco(
      cep: campo('cep'),
      logradouro: campo('logradouro'),
      complemento: campo('complemento'),
      bairro: campo('bairro'),
      localidade: campo('localidade'),
      uf: campo('uf'),
      estado: campo('estado'),
      ibge: campo('ibge'),
      ddd: campo('ddd'),
    );
  }
}
