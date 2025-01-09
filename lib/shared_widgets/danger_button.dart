import 'package:flutter/material.dart';

class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    this.isSubmitting = false,
    required this.buttonIcon,
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
            color: Colors.white,
          ),  
          SizedBox(width: 8),
          Text(
            isSubmitting ? 'Processing...' : buttonText,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.red),
        padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        elevation: WidgetStatePropertyAll(10.0),
      ),
    );
  }
}
