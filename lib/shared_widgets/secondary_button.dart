import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    this.isSubmitting = false ,
    this.buttonIcon,
    required this.buttonText,
    required this.buttonOnPressed,
  });

  final IconData? buttonIcon;
  final String buttonText;
  final bool isSubmitting;
  final Function() buttonOnPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isSubmitting
          ? null
          : () {
              buttonOnPressed();
            },
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            buttonIcon,
            color: Colors.black,
          ),
          SizedBox(width: 8),
          Text(
            isSubmitting ? 'Processing...' : buttonText,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      style: ButtonStyle(
        backgroundColor:
            WidgetStatePropertyAll(const Color.fromARGB(255, 248, 237, 183)),
        padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        elevation: WidgetStatePropertyAll(10.0),
      ),
    );
  }
}
