import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/screens/auth/verify_email/verify_email_first.dart';
import 'package:expense_tracker/screens/expense/partials/expense_summary.dart';
import 'package:expense_tracker/screens/expense/partials/expenses_show.dart';
import 'package:expense_tracker/screens/expense/partials/index_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:expense_tracker/screens/expense/partials/index_test.dart';
import 'package:expense_tracker/screens/expense/partials/create_new_inputs.dart';

class Expense extends StatefulWidget {
  const Expense({super.key, required this.ref});
  final WidgetRef ref;
  @override
  ExpenseState createState() => ExpenseState();
}

class ExpenseState extends State<Expense> {
  Map<String, dynamic> fetchedData = {};
  bool isLoading = true;
  String? paginateUrl;
  String? loadingError;

  @override
  void initState() {
    super.initState();
    loadData(widget.ref);
  }

  Future<void> loadData(ref) async {
    final globalState = ref.watch(globalStateNotifierProvider);
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('$API_URL/date'),
      headers: {
        'Authorization': 'Bearer ${globalState['auth']['token']['text']}'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          fetchedData = data['data'];
          paginateUrl = data['data']['dates']['next_page_url'];
        });
      } else if (data['status'] == 'Unauthenticated') {
        globalStateNotifier.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have been logged out.'),
          ),
        );
      } else {
        // print(data);
        setState(() {
          loadingError = 'An error occurred. Please try again later.';
        });
      }
    } else {
      // print('Error: ${response.statusCode}');
      setState(() {
        loadingError = 'An error occurred. Please try again later.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalState = widget.ref.watch(globalStateNotifierProvider);
    final globalStateNotifier =
        widget.ref.read(globalStateNotifierProvider.notifier);

    final widgetContainerDecoration = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      color: Theme.of(context).colorScheme.onSecondary.withAlpha(100),
      border: Border.all(color: Colors.grey, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    );

    if (globalState['auth']['user']['email_verified_at'] == null) {
      return Container(
        padding: EdgeInsets.all(8.0),
        decoration: widgetContainerDecoration,
        child: VerifyEmailFirst(ref: widget.ref),
      );
    }

    if (isLoading) {
      return Text('Loading ...');
    }

    return loadingError != null
        ? Center(child: Text(loadingError!))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (globalState['auth']['user']['email'] == 'test@aly-h.com')
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: widgetContainerDecoration,
                  child: IndexTest(
                    loadData: () => loadData(widget.ref),
                    ref: widget.ref,
                  ),
                ),
              if (globalState['auth']['user']['email'] == 'test@aly-h.com')
                SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: widgetContainerDecoration,
                child: CreateNewInputs(
                  loadData: () => loadData(widget.ref),
                  ref: widget.ref,
                  categories: fetchedData['categories'],
                ),
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: widgetContainerDecoration,
                child: IndexSearch(
                  categories: fetchedData['categories'],
                  filters: fetchedData['filters'],
                  ref: widget.ref,
                  updateFetchedData: (newData) {
                    setState(() {
                      fetchedData = newData['data'];
                      paginateUrl = newData['data']['dates']['next_page_url'];
                    });
                  },
                ),
              ),
              if (fetchedData['expenseData']?['startDate'] != null &&
                  fetchedData['expenseData']?['endDate'] != null)
                SizedBox(height: 32),
              if (fetchedData['expenseData']?['startDate'] != null &&
                  fetchedData['expenseData']?['endDate'] != null)
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: widgetContainerDecoration,
                  child: ExpenseSummary(
                    expenseData: fetchedData['expenseData'],
                    filters: fetchedData['filters'],
                  ),
                ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: widgetContainerDecoration,
                child: fetchedData['dates']['data'].isEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No Expenses Found.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ExpensesShow(
                        fetchedData: fetchedData,
                        paginateUrl: paginateUrl,
                        updateFetchedData: (newData) {
                          setState(() {
                            fetchedData = newData;
                          });
                        },
                        ref: widget.ref,
                      ),
              ),
            ],
          );
  }
}
