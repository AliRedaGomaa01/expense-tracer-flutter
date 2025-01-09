import 'dart:convert';

import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/danger_button.dart';
import 'package:expense_tracker/shared_widgets/input_error.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CreateNewInputs extends StatefulWidget {
  final VoidCallback loadData;
  final WidgetRef ref;

  final List<dynamic> categories;

  const CreateNewInputs(
      {super.key,
      required this.loadData,
      required this.ref,
      required this.categories});

  @override
  CreateNewInputsState createState() => CreateNewInputsState();
}

class CreateNewInputsState extends State<CreateNewInputs> {
  final _formKey = GlobalKey<FormState>();
  dynamic _date;
  String _formattedDate = '';
  Map _errors = {};
  bool _isProcessing = false;
  final List _expenses = [];

  // Function to show the DatePicker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: DateTime(2100), // Latest selectable date
    );

    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
        _formattedDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      });
    }
  }

  void _addNewExpense() {
    setState(() {
      _expenses.add({
        'name': '',
        'price': '',
        'category_id': '1',
      });
    });
  }

  void _removeExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
        _errors = {};
      });

      final globalState = widget.ref.watch(globalStateNotifierProvider);
      final globalStateNotifier =
          widget.ref.read(globalStateNotifierProvider.notifier);

      final response = await http.post(
        Uri.parse('$API_URL/expenses'),
        headers: {
          'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'date': _formattedDate,
          'expenses': _expenses,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added successfully.'),
            ),
          );
          setState(() {
            _expenses.clear();
          });
          widget.loadData();
        } else if (data['status'] == 'error') {
          setState(() {
            _errors = data['errors'];
          });
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
    }
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add New Expenses',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32),
          PrimaryButton(
              buttonIcon: Icons.date_range,
              buttonText: 'Click to pick a date',
              buttonOnPressed: () => _pickDate(context)),
          SizedBox(height: 16),
          PrimaryButton(
            buttonIcon: Icons.date_range,
            buttonText: _date == null
                ? "No selected date"
                : "Selected date is: ${_date!.day > 9 ? '' : '0'}${_date!.day}-${_date!.month > 9 ? '' : '0'}${_date!.month}-${_date!.year}",
            buttonOnPressed: () {},
          ),
          if (_errors.containsKey('date')) SizedBox(height: 16),
          if (_errors.containsKey('date')) InputError(errors: _errors['date']),
          if (_expenses.isNotEmpty) SizedBox(height: 16),
          ..._expenses.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> expense = entry.value;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: index % 2 == 0
                      ? Theme.of(context).colorScheme.onPrimary.withAlpha(150)
                      : Theme.of(context).colorScheme.secondary.withAlpha(150),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Expense Name',
                        hintText: 'Enter the expense name',
                      ),
                      onChanged: (value) => expense['name'] = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an expense name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        hintText: 'Enter the price',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => expense['price'] = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        hintText: 'Select a category',
                      ),
                      value: expense['category_id'],
                      items: widget.categories.map((category) {
                        return DropdownMenuItem(
                          value: category['id'].toString(),
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) => expense['category_id'] = value,
                    ),
                    SizedBox(height: 16),
                    DangerButton(
                        buttonIcon: Icons.delete,
                        buttonText: "Remove Expense",
                        buttonOnPressed: () => _removeExpense(index)),
                  ],
                ),
              ),
            );
          }),
          if (_errors.containsKey('expenses')) SizedBox(height: 16),
          if (_errors.containsKey('expenses'))
            InputError(errors: _errors['expenses']),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryButton(
                  buttonIcon: Icons.edit,
                  buttonText: "Add New Expense Field",
                  buttonOnPressed: _addNewExpense),
              PrimaryButton(
                  buttonIcon: Icons.done,
                  buttonText: "Submit",
                  isSubmitting: _isProcessing,
                  buttonOnPressed: _submit),
            ],
          ),
        ],
      ),
    );
  }
}
