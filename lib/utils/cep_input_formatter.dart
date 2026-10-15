import 'package:flutter/services.dart';

/// Máscara de CEP no formato 00000-000.
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > 8) digitos = digitos.substring(0, 8);

    final texto = digitos.length > 5
        ? '${digitos.substring(0, 5)}-${digitos.substring(5)}'
        : digitos;

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
