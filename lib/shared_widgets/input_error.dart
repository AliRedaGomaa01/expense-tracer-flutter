import 'package:flutter/material.dart';

class InputError extends StatelessWidget {
  final List<String> errors;

  const InputError({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: errors.map((error) => Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          error,
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
      )).toList(),
    );
  }
}