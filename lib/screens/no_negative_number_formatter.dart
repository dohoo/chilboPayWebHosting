import 'package:flutter/services.dart';

class NoNegativeNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.contains('-')) {
      // If the new value contains a negative sign, return the old value.
      return oldValue;
    }
    return newValue;
  }
}
