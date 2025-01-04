import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/layouts/my_app.dart';
import 'package:expense_tracker/screens/auth/reset_password/reset_password.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:expense_tracker/shared_widgets/secondary_button.dart';
import 'package:expense_tracker/utils/sqflite_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:expense_tracker/shared_widgets/input_error.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  // String _email = '';
  Map<String, List<String>> _errors = {};
  bool _isSubmitting = false;
  String _successMessage = '';
  final TextEditingController emailController = TextEditingController();
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errors = {};
        _successMessage = '';
        _isSubmitting = true;
      });

      try {
        final db = KeyValueDatabase();
        await db.setValue('reset_password_email', emailController.text);

        final response = await http.post(
          Uri.parse('$API_URL/forgot-password'),
          body: {'email': emailController.text},
        );

        final responseData = json.decode(response.body);

        if (responseData['status'] == 'errors') {
          setState(() {
            _errors = Map<String, List<String>>.from(responseData['errors']);
          });
        } else if (responseData['status'] == 'success') {
          setState(() {
            _successMessage =
                'Password reset token has been sent to your email.';
            emailController.text = '';
          });
          _formKey.currentState!.reset();
        }
      } catch (error) {
        // print(error);
        setState(() {
          _errors = {
            'form': ['An error occurred. Please try again.']
          };
        });
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(
      childWidgetTitle: 'Forgot Password',
      childWidgetContext: context,
      childWidget: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Forgot Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  if (_errors.containsKey('form'))
                    InputError(errors: _errors['form']!),
                  Text(
                    'Enter your email address to get an email containing a token to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required.';
                      }
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email.';
                      }
                      return null;
                    },
                  ),
                  if (_errors.containsKey('email'))
                    InputError(errors: _errors['email']!),
                  SizedBox(height: 16),
                  if (!_successMessage.isNotEmpty)
                    PrimaryButton(
                      buttonText: 'Send Email',
                      buttonIcon: Icons.email,
                      buttonOnPressed:
                          _isSubmitting ? () {} : () => _handleSubmit(),
                      isSubmitting: _isSubmitting,
                    ),
                  SizedBox(height: 16),
                  if (_successMessage.isNotEmpty)
                    SecondaryButton(
                      buttonText: 'Click if you have received email',
                      buttonIcon: Icons.link,
                      buttonOnPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ResetPassword()));
                      },
                      isSubmitting: _isSubmitting,
                    ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _successMessage,
                        style: TextStyle(color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
