import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/custom_outlined_button.dart';
import 'package:expense_tracker/shared_widgets/danger_button.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'input_error.dart';

class EditCurrentExpenses extends StatefulWidget {
  final List<dynamic> expenses;
  final List<dynamic> categories;
  final Function removeEmptyDate;
  final WidgetRef ref;

  const EditCurrentExpenses(
      {super.key,
      required this.expenses,
      required this.categories,
      required this.removeEmptyDate,
      required this.ref});

  @override
  EditCurrentExpensesState createState() => EditCurrentExpensesState();
}

class EditCurrentExpensesState extends State<EditCurrentExpenses> {
  late List<dynamic> currentExpenses;
  String status = '';
  Map<String, dynamic> errors = {};
  int? statusIndex;
  bool openDeletionModal = false;
  int? openDeletionModalId;

  @override
  void initState() {
    super.initState();
    currentExpenses = List.from(widget.expenses);
  }

  void closeModal(context) {
    setState(() {
      openDeletionModal = false;
      openDeletionModalId = null;
    });
    Navigator.pop(context);
  }

  Future<void> updateExpense(int id, int index) async {
    final globalState = widget.ref.watch(globalStateNotifierProvider);
    final globalStateNotifier =
        widget.ref.read(globalStateNotifierProvider.notifier);

    setState(() {
      status = 'processing';
      statusIndex = index;
    });

    final expense =
        currentExpenses.firstWhere((expense) => expense['id'] == id);
    final response = await http.put(
      Uri.parse('$API_URL/expenses/$id'),
      headers: {
        'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
        'Content-Type': 'application/json',
      },
      body: json.encode(expense),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          status = 'success';
        });
      } else if (data['status'] == 'Unauthenticated') {
        globalStateNotifier.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have been logged out.'),
          ),
        );
      } else if (data['status'] == 'error') {
        setState(() {
          errors = {
            ...errors,
            'expenses': {index.toString(): data['errors']}
          };
        });
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

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        status = '';
        statusIndex = null;
      });
    });
  }

  Future<void> deleteExpense(int id, int index) async {
    final globalState = widget.ref.watch(globalStateNotifierProvider);
    final globalStateNotifier =
        widget.ref.read(globalStateNotifierProvider.notifier);

    final response = await http.delete(
      Uri.parse('$API_URL/expenses/$id'),
      headers: {
        'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        // closeModal();
        setState(() {
          currentExpenses.removeWhere((expense) => expense['id'] == id);
        });
        if (currentExpenses.isEmpty) {
          widget.removeEmptyDate();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted successfully')),
        );
      } else if (data['status'] == 'Unauthenticated') {
        globalStateNotifier.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have been logged out.')),
        );
      } else if (data['status'] == 'error') {
        setState(() {
          errors = data['errors'];
        });
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

  void showDeleteConfirmationDialog(int id, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            CustomOutlinedButton(
                buttonText: "Cancel",
                buttonOnPressed: () => closeModal(context)),
            DangerButton(
                buttonIcon: Icons.delete,
                buttonText: "Delete",
                buttonOnPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  deleteExpense(id, index);
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: currentExpenses.asMap().entries.map((entry) {
        final index = entry.key;
        final expense = entry.value;
        final id = expense['id'];

        return Container(
          key: Key('${id.toString()}-expense-id'),
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: index % 2 == 0
                ? Theme.of(context).colorScheme.primary.withAlpha(200)
                : Theme.of(context).colorScheme.primary.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(50),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        openDeletionModal = true;
                        openDeletionModalId = id;
                      });
                      showDeleteConfirmationDialog(id, index);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              TextFormField(
                initialValue: expense['name'],
                decoration: InputDecoration(
                  labelText: 'Expense description',
                  hintText: 'Enter the expense description',
                  errorText: errors['expenses']?[index.toString()]?['name'],
                ),
                onChanged: (value) {
                  setState(() {
                    currentExpenses[index]['name'] = value;
                  });
                },
              ),
              TextFormField(
                initialValue: expense['price'].toString(),
                decoration: InputDecoration(
                  labelText: 'Expenses Price',
                  hintText: 'Enter the expenses price',
                  errorText: errors['expenses']?[index.toString()]?['price'],
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    currentExpenses[index]['price'] =
                        double.tryParse(value) ?? 0;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: expense['category_id'].toString(),
                decoration: InputDecoration(
                  labelText: 'Category of expenses',
                  errorText: errors['expenses']?[index.toString()]
                      ?['category_id'],
                ),
                items:
                    widget.categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    currentExpenses[index]['category_id'] = int.parse(value!);
                  });
                },
              ),
              SizedBox(height: 16),
              PrimaryButton(
                  buttonIcon: Icons.update,
                  buttonText: (status == 'processing' && statusIndex == index
                      ? 'Processing...'
                      : (status == 'success' && statusIndex == index
                          ? 'Updated Successfully'
                          : 'Update')),
                  buttonOnPressed: statusIndex != index
                      ? () => updateExpense(id, index)
                      : () {},
                  buttonColor: status == 'success' && statusIndex == index
                      ? Colors.green
                      : (status == 'processing' && statusIndex == index
                          ? Colors.yellow[700]
                          : null)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
