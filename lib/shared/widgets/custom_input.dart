import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
