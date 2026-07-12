import 'package:flutter/material.dart';

Widget buildTextField(
  String label,
  IconData icon,
  TextEditingController controller, {
  bool isPassword = false,
  bool isEmail = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        if (isEmail &&
            !RegExp(
              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
            ).hasMatch(value)) {
          return "Enter a valid email";
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
