import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/danger_button.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IndexTest extends StatelessWidget {
  final VoidCallback loadData;
  final WidgetRef ref;

  const IndexTest({super.key, required this.loadData, required this.ref});

  void onSeed(context) async {
    final globalState = ref.watch(globalStateNotifierProvider);
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);

    final response = await http.post(
      Uri.parse('$API_URL/expenses/seed'),
      headers: {
        'Authorization': 'Bearer ${globalState['auth']['token']['text']}'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seeded successfully.'),
          ),
        );
        loadData();
      } else if (data['status'] == 'Unauthenticated') {
        globalStateNotifier.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have been logged out.'),
          ),
        );
      } else {
        // print(data.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later.'),
          ),
        );
      }
    } else {
      // print('Error: ${response.body.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
  }

  void onDeleteAll(context) async {
    final globalState = ref.watch(globalStateNotifierProvider);
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);

    final response = await http.delete(
      Uri.parse('$API_URL/expenses/delete-all'),
      headers: {
        'Authorization': 'Bearer ${globalState['auth']['token']['text']}'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted successfully.'),
          ),
        );

        loadData();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Testing',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
                buttonIcon: Icons.add,
                buttonText: "Add Test Data",
                buttonOnPressed: () => onSeed(context)),
            SizedBox(height: 16),
            DangerButton(
                buttonIcon: Icons.delete_forever,
                buttonText: "Delete All Data",
                buttonOnPressed: () => onDeleteAll(context)),
          ],
        ),
      ],
    );
  }
}
