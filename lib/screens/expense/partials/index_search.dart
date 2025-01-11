import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IndexSearch extends StatefulWidget {
  final Function(Map<String, dynamic>) updateFetchedData;
  final List categories;
  final Map filters;
  final WidgetRef ref;

  const IndexSearch({
    super.key,
    required this.updateFetchedData,
    required this.categories,
    required this.filters,
    required this.ref,
  });

  @override
  IndexSearchState createState() => IndexSearchState();
}

class IndexSearchState extends State<IndexSearch> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _startDate = '';
  String _endDate = '';
  String? _categoryId = '0';
  bool _isLoading = false;
  Map _errors = {};

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> filters = Map.from(widget.filters);
    _name = filters['name'] ?? '';
    _startDate = filters['start_date'] ?? '';
    _endDate = filters['end_date'] ?? '';
    _categoryId = filters['category_id'] ?? '0';
  }

  Future<void> _handleSearch() async {
    if (_formKey.currentState!.validate()) {
      final globalState = widget.ref.watch(globalStateNotifierProvider);
      final globalStateNotifier =
          widget.ref.read(globalStateNotifierProvider.notifier);

      setState(() {
        _isLoading = true;
        _errors = {};
      });

      try {
        final Map<String, String> queryParameters = {
          'name': _name,
          'start_date': _startDate,
          'end_date': _endDate,
          'category_id': _categoryId!,
        };

        final uri = Uri.parse(
            "$API_URL/date?${queryParameters.keys.map((key) => '$key=${queryParameters[key]}').join('&')}");

        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('filtered successfully.'),
              ),
            );
            widget.updateFetchedData(data);
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
      } catch (error) {
        print('Error: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _startDate != '' ? DateTime.parse(_startDate) : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _startDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate != '' ? DateTime.parse(_endDate) : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _endDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter Results',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32),
          PrimaryButton(
              buttonIcon: Icons.date_range,
              buttonText: 'pick start date',
              buttonOnPressed: () => _pickStartDate(context)),
          SizedBox(height: 16),
          PrimaryButton(
            buttonIcon: Icons.date_range,
            buttonColor:
                _startDate == '' ? Colors.pink : Colors.green.withAlpha(50),
            buttonText: _startDate == '' ? "No selected date" : "$_startDate",
            buttonOnPressed: () {},
          ),
          SizedBox(height: 32),
          PrimaryButton(
              buttonIcon: Icons.date_range,
              buttonText: 'pick end date',
              buttonOnPressed: () => _pickEndDate(context)),
          SizedBox(height: 16),
          PrimaryButton(
            buttonIcon: Icons.date_range,
            buttonColor:
                _endDate == '' ? Colors.pink : Colors.green.withAlpha(50),
            buttonText: _endDate == '' ? "No selected date" : "$_endDate",
            buttonOnPressed: () {},
          ),
          SizedBox(height: 32),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Expense Name',
              hintText: 'Enter the expense name',
            ),
            onChanged: (value) => _name = value,
            validator: (value) {
              return null;
            },
          ),
          SizedBox(height: 32),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Category',
              hintText: 'Select a category',
            ),
            value: _categoryId,
            items: [
              DropdownMenuItem<String>(
                value: '0',
                child: Text('All Categories'),
              ),
              ...widget.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'].toString(),
                  child: Text(category['name']),
                );
              }).toList(),
            ],
            onChanged: (String? value) {
              setState(() {
                _categoryId = value;
              });
            },
          ),
          SizedBox(height: 32),
          PrimaryButton(
            buttonIcon: Icons.search,
            buttonText: 'Search',
            isSubmitting: _isLoading,
            buttonOnPressed: _handleSearch,
          ),
        ],
      ),
    );
  }
}
