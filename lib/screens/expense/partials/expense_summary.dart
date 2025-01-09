import 'package:flutter/material.dart';

class ExpenseSummary extends StatelessWidget {
  final Map<String, dynamic> expenseData;
  final Map<String, dynamic>? filters;

  const ExpenseSummary({super.key, required this.expenseData, this.filters});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          color: Colors.red[50],
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700]),
              children: [
                TextSpan(text: 'Total expenses '),
                if (filters != null && filters!['name'] != null)
                  TextSpan(
                    text: ' for search terms (${filters!['name']}) ',
                    style: TextStyle(
                        color: Colors.red[700], fontWeight: FontWeight.w600),
                  ),
                TextSpan(text: 'for '),
                TextSpan(
                  text: ' ${expenseData['category']} ',
                  style: TextStyle(
                      color: Colors.red[700], fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          color: Colors.yellow[50],
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700]),
              children: [
                TextSpan(text: 'From date '),
                TextSpan(
                  text: '${expenseData['startDate']} ',
                  style: TextStyle(
                      color: Colors.blue[700], fontWeight: FontWeight.w600),
                ),
                TextSpan(text: 'to date '),
                TextSpan(
                  text: '${expenseData['endDate']} ',
                  style: TextStyle(
                      color: Colors.blue[700], fontWeight: FontWeight.w600),
                ),
                TextSpan(text: 'over: '),
                TextSpan(
                  text: '${expenseData['daysBetween']} ',
                  style: TextStyle(
                      color: Colors.blue[700], fontWeight: FontWeight.w600),
                ),
                TextSpan(text: 'days'),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          color: Colors.red[50],
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700]),
              children: [
                TextSpan(text: 'is: '),
                TextSpan(
                  text:
                      '${double.parse(expenseData['sum'].toString()).toStringAsFixed(2)} ',
                  style: TextStyle(
                      color: Colors.green[700], fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'at an average of: '),
                TextSpan(
                  text:
                      '${double.parse(expenseData['averagePerDay'].toString()).toStringAsFixed(2)} ',
                  style: TextStyle(
                      color: Colors.green[700], fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'per day\n\n'),
                TextSpan(text: 'and an average of: '),
                TextSpan(
                  text:
                      '${(double.parse(expenseData['averagePerDay'].toString()) * 365 / 12).toStringAsFixed(2)} ',
                  style: TextStyle(
                      color: Colors.green[700], fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'per month\n'),
                TextSpan(text: 'and an average of: '),
                TextSpan(
                  text:
                      '${(double.parse(expenseData['averagePerDay'].toString()) * 365).toStringAsFixed(2)} ',
                  style: TextStyle(
                      color: Colors.green[700], fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'per year'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
