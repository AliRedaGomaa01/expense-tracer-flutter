import 'package:flutter/material.dart';

class InputError extends StatelessWidget {
  final List<dynamic>? errors;

  const InputError({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    if (errors == null || errors!.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey),
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: errors == null
              ? []
              : errors!
                  .map((error) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          error,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ))
                  .toList(),
        ),
      ),
    );
  }
}
