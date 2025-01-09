import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_current_expenses.dart';

class ExpensesShow extends StatefulWidget {
  final Map<String, dynamic> fetchedData;
  final String? paginateUrl;
  final Function(Map<String, dynamic>) updateFetchedData;
  final WidgetRef ref;

  const ExpensesShow({
    super.key,
    required this.fetchedData,
    this.paginateUrl,
    required this.updateFetchedData,
    required this.ref,
  });

  @override
  ExpensesShowState createState() => ExpensesShowState();
}

class ExpensesShowState extends State<ExpensesShow> {
  bool isLoading = false;

  Future<void> loadMoreData() async {
    if (widget.paginateUrl == null || isLoading) return;

    final globalState = widget.ref.watch(globalStateNotifierProvider);
    final globalStateNotifier =
        widget.ref.read(globalStateNotifierProvider.notifier);

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(widget.paginateUrl!),
        headers: {
          'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final newDates = [
            ...widget.fetchedData['dates']['data'],
            ...data['data']['dates']['data']
          ];
          final updatedFetchedData = {
            ...widget.fetchedData,
            'dates': {
              ...data['data']['dates'],
              'data': newDates,
            },
          };
          widget.updateFetchedData(updatedFetchedData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded more data successfully.'),
            ),
          );
        } else if (data['status'] == 'Unauthenticated') {
          globalStateNotifier.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have been logged out.'),
            ),
          );
        } else {
          print(data.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred. Please try again later.'),
            ),
          );
        }
      } else {
        print('Error: ${response.body.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later.'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void removeEmptyDate(int id) {
    final List<dynamic> newDates = widget.fetchedData['dates']['data']
        .where((date) => date['id'] != id)
        .toList();

    final updatedFetchedData = {
      ...widget.fetchedData,
      'dates': {
        ...widget.fetchedData['dates'],
        'data': newDates,
      },
    };
    widget.updateFetchedData(updatedFetchedData);
  }

  @override
  Widget build(BuildContext context) {
    final dates = widget.fetchedData['dates']['data'] as List<dynamic>;

    return Column(
      children: [
        ...dates.map((date) {
          final expenses = date['expenses'] as List<dynamic>;
          return Column(
            key: Key(
              '${date['id'].toString()}-date-id',
            ),
            children: [
              Text(
                date['date'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              EditCurrentExpenses(
                expenses: expenses,
                removeEmptyDate: () => removeEmptyDate(date['id']),
                categories: widget.fetchedData['categories'],
                ref: widget.ref,
              ),
            ],
          );
        }).toList(),
        if (widget.paginateUrl != null) SizedBox(height: 32),
        if (widget.paginateUrl != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PrimaryButton(
                    isSubmitting: isLoading,
                    buttonIcon: Icons.more_horiz,
                    buttonText: 'Load More',
                    buttonOnPressed: loadMoreData),
              ),
            ],
          ),
      ],
    );
  }
}
