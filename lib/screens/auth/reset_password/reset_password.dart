import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/layouts/my_app.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:expense_tracker/utils/sqflite_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:expense_tracker/utils/validate_password.dart';
import 'package:expense_tracker/shared_widgets/input_error.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({
    super.key,
  });

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  bool _passwordVisible = false;
  bool _isSubmitting = false;
  String? _successMessage;
  Map<String, List<String>> _errors = {};

  @override
  void initState() {
    super.initState();
  }

  void _handleSubmit(context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _errors = {};
        _successMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse('$API_URL/reset-password'),
          body: {
            'email': _emailController.text,
            'token': _tokenController.text,
            'password': _passwordController.text,
            'password_confirmation': _passwordConfirmationController.text,
          },
        );

        final responseData = json.decode(response.body);

        if (responseData['status'] == 'error') {
          setState(() {
            _errors = Map<String, List<String>>.from(responseData['errors']);
          });
        } else if (responseData['status'] == 'success') {
          final db = KeyValueDatabase();
          await db.deleteValue('reset_password_email');

          setState(() {
            _successMessage =
                'Password reset successfully. You will be redirected soon.';
          });

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ),
          );
        }
      } catch (error) {
        // print(error);
        setState(() {
          _errors = {
            'form': ['An error occurred. Please try again later.'],
          };
        });
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(
      childWidgetTitle: 'Reset Password',
      childWidgetContext: context,
      childWidget: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reset Password',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            if (_errors.containsKey('form'))
              InputError(errors: _errors['form']!),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Token',
                hintText: 'Enter the token sent to your email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Token is required';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter a strong password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
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
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordConfirmationController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter the password',
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'The password confirmation does not match';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            PrimaryButton(
              buttonText: 'Reset Password',
              buttonIcon: Icons.done,
              buttonOnPressed:
                  _isSubmitting ? () {} : () => _handleSubmit(context),
              isSubmitting: _isSubmitting,
            ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
