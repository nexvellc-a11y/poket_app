import 'package:flutter/material.dart';

// Widget buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
//     );
//   }

//   Widget buildTextField(
//     TextEditingController controller, {
//     bool isNumeric = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: TextField(
//         controller: controller,
//         keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
//         decoration: const InputDecoration(border: OutlineInputBorder()),
//       ),
//     );
//   }

//   Widget buildDropdown(
//     String? value,
//     List<String> items,
//     ValueChanged<String?> onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         items:
//             items
//                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                 .toList(),
//         onChanged: onChanged,
//         decoration: const InputDecoration(border: OutlineInputBorder()),
//       ),
//     );
//   }

// Reusable Widgets
Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

Widget buildTextField(
  TextEditingController controller,
  String hintText, {
  bool isNumeric = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? "This field is required" : null,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

Widget buildDropdown(
  String hint,
  String? selectedValue,
  List<String> items,
  void Function(String?) onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: Text(hint),
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Please select an option" : null,
    ),
  );
}
