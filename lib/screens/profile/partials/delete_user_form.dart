import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/layouts/my_app.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/input_error.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteUserForm extends StatefulWidget {
  const DeleteUserForm({super.key});
  @override
  DeleteUserFormState createState() => DeleteUserFormState();
}

class DeleteUserFormState extends State<DeleteUserForm> {
  final _passwordController = TextEditingController();
  bool _isDeleting = false;
  bool _showPassword = false;
  Map _errors = {};

  void _handleDelete(WidgetRef ref, context) async {
    final globalState = ref.watch(globalStateNotifierProvider);
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);

    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('$API_URL/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
        },
        body: jsonEncode({
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        globalStateNotifier.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deleted successfully.')),
        );
      } else if (data['status'] == 'error') {
        setState(() {
          _errors = data['errors'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete account. Please try again.')),
        );
      }
    } catch (e) {
      // print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final globalState = ref.watch(globalStateNotifierProvider);
      final globalStateNotifier =
          ref.read(globalStateNotifierProvider.notifier);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete Account',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 16),
          Text(
            'Once your account is deleted, all of its resources and data will be permanently deleted. Before deleting your account, please download any data or information that you wish to retain.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
            obscureText: !_showPassword,
          ),
          InputError(errors: _errors['password']),
          SizedBox(height: 24),
          PrimaryButton(
            buttonText: 'Delete Account',
            isSubmitting: _isDeleting,
            buttonIcon: Icons.delete,
            buttonOnPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext alertContext) {
                  return AlertDialog(
                    title: Text('Are you sure?'),
                    content: Text(
                        'Once your account is deleted, all of its resources and data will be permanently deleted. This action cannot be undone.'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(alertContext).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          Navigator.of(alertContext).pop();
                          _handleDelete(ref, context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      );
    });
  }
}
