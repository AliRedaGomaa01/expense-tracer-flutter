import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/input_error.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:expense_tracker/utils/validate_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdatePasswordForm extends StatefulWidget {
  const UpdatePasswordForm({super.key});
  @override
  UpdatePasswordFormState createState() => UpdatePasswordFormState();
}

class UpdatePasswordFormState extends State<UpdatePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  bool _isSubmitting = false;
  bool _showPassword = false;
  Map _errors = {};

  void _handleSubmit(globalState, globalStateNotifier, context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _errors = {};
      });

      try {
        final response = await http.put(
          Uri.parse('$API_URL/profile-password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
          },
          body: jsonEncode({
            'current_password': _currentPasswordController.text,
            'password': _passwordController.text,
            'password_confirmation': _passwordConfirmationController.text,
          }),
        );

        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password updated successfully')),
          );
          _currentPasswordController.clear();
          _passwordController.clear();
          _passwordConfirmationController.clear();
        } else if (data['status'] == 'error') {
          setState(() {
            _errors = data['errors'];
          });
        }
      } catch (e) {
        // print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final globalState = ref.watch(globalStateNotifierProvider);
      final globalStateNotifier =
          ref.read(globalStateNotifierProvider.notifier);

      return Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Update Password',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                    labelText: 'Current Password',
                    hintText: 'Enter your current password',
                    suffixIcon: IconButton(
                        icon: Icon(_showPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        })),
                obscureText: _showPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              if (_errors['current_password'] != null)
                InputError(errors: _errors['current_password']!),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter a new password',
                ),
                obscureText: _showPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  final passwordErrors = validatePassword(
                      password: value,
                      passwordConfirmation:
                          _passwordConfirmationController.text);
                  if (passwordErrors.isNotEmpty) {
                    return passwordErrors.join('\n');
                  }
                  return null;
                },
              ),
              InputError(errors: _errors['password']),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordConfirmationController,
                decoration:
                    InputDecoration(labelText: 'Confirm New Password'),
                obscureText: _showPassword,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              InputError(errors: _errors['password_confirmation']),
              SizedBox(height: 24),
              PrimaryButton(
                  buttonText: 'Update Password',
                  buttonIcon: Icons.password,
                  buttonOnPressed: () => _handleSubmit(
                      globalState, globalStateNotifier, context),
                  isSubmitting: _isSubmitting),
            ],
          ),
        ),
      );
    });
  }
}
