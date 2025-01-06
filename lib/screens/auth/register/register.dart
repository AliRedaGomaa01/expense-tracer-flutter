import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:expense_tracker/utils/validate_password.dart';
import 'package:expense_tracker/shared_widgets/input_error.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, List<String>> _errors = {};
  bool _isSubmitting = false;
  bool _showPassword = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void _setSubmitting(bool value) => setState(() => _isSubmitting = value);
  void _setErrors(Map<String, List<String>> errors) =>
      setState(() => _errors.addAll(errors));

  Future<void> _handleSubmit(
      context, GlobalStateNotifier globalStateNotifier) async {
    if (!_formKey.currentState!.validate()) return;

    final passwordErrors = validatePassword(
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text);

    if (passwordErrors.isNotEmpty) {
      _setErrors({'password': passwordErrors});
      return;
    }

    _setSubmitting(true);
    _setErrors({}); // Clear errors

    try {
      final response = await http.post(
        Uri.parse('$API_URL/register'),
        body: {
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        globalStateNotifier.updateGlobalState({
          'auth': responseData['data'],
          'status': 'auth',
          'selectedTabIndex': 0,
        });
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (response.statusCode == 200 &&
          responseData['status'] == 'error') {
        _setErrors(Map<String, List<String>>.from(responseData['errors']));
      }
    } catch (e) {
      _setErrors({
        'form': ['An error occurred. Please try again.']
      });
    } finally {
      _setSubmitting(false);
    }
  }

  Widget buildErrorText(String? error) {
    return error == null ? SizedBox.shrink() : InputError(errors: [error]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final globalStateNotifier =
          ref.read(globalStateNotifierProvider.notifier);
    
      return Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Register a new account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildErrorText(_errors['form']?.join(', ')),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Name',
                  errorText: _errors['name']?.join(', '),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Name is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  labelText: 'Email',
                  errorText: _errors['email']?.join(', '),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Email is required';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value!)) {
                    return 'Invalid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                  errorText: _errors['password']?.join(', '),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Password is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                  labelText: 'Confirm Password',
                  errorText: _errors['password_confirmation']?.join(', '),
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              PrimaryButton(
                buttonText: 'Register',
                buttonIcon: Icons.app_registration_outlined,
                buttonOnPressed: () =>
                    _handleSubmit(context, globalStateNotifier),
                isSubmitting: _isSubmitting,
              ),
            ],
          ),
        ),
      );
    });
  }
}
