import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    this.isSubmitting = false,
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
    return OutlinedButton(
      onPressed: buttonOnPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            buttonIcon,
            color: Theme.of(context).iconTheme.color,
          ),
          SizedBox(width: 8),
          Text(
            buttonText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
