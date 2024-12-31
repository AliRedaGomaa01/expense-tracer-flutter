import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '♥ Welcome ♥',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Thank you for choosing our personal expense tracking app!',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Our app is designed to help you manage your daily expenses easily and effectively, allowing you to organize your budget in a smart and hassle-free way.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'By tracking your expenses, you’ll gain a clear and comprehensive understanding of your financial habits, enabling you to make better financial decisions.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Simply record your daily expenses for 90 days to calculate your average spending per day, month, and year for better financial planning.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Thank you again, and we wish you a fantastic experience using the app!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
