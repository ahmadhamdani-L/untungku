import 'package:flutter/material.dart';
import '../../domain/input_validation.dart';
import '../../domain/money.dart';

class IntegerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int min, max;
  final ValueChanged<String>? onChanged;
  const IntegerField({
    super.key,
    required this.controller,
    required this.label,
    this.min = 0,
    this.max = maxMoney,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(signed: min < 0),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (value) => integerInputError(value, label, min: min, max: max),
    decoration: InputDecoration(labelText: label),
    onChanged: onChanged,
  );
}
