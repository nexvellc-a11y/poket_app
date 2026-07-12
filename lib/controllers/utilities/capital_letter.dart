import 'package:flutter/services.dart';

class FirstLetterCapitalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // If the text is unchanged except for case, return as is
    if (oldValue.text.toLowerCase() == newValue.text.toLowerCase() &&
        oldValue.text.isNotEmpty) {
      return newValue;
    }

    // Capitalize the first letter
    final String newText =
        newValue.text.isNotEmpty
            ? newValue.text[0].toUpperCase() +
                (newValue.text.length > 1 ? newValue.text.substring(1) : '')
            : newValue.text;

    return TextEditingValue(text: newText, selection: newValue.selection);
  }
}
