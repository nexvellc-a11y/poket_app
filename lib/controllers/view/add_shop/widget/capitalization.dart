import 'package:flutter/widgets.dart';

class CapitalizingTextController extends TextEditingController {
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it as is.
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalize the first letter of the new value.
    final capitalizedText =
        newValue.text[0].toUpperCase() + newValue.text.substring(1);

    // Return a new TextEditingValue with the capitalized text.
    return TextEditingValue(
      text: capitalizedText,
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}
