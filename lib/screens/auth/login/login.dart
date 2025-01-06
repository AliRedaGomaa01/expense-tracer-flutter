import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/layouts/my_app.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/screens/auth/forgot_password/forgot_password.dart';
import 'package:expense_tracker/shared_widgets/input_error.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  bool isSubmitting = false;
  Map<String, List<String>> errors = {};

  void handleChange() {
    if (errors.isNotEmpty) {
      setState(() {
        errors = {};
      });
    }
  }

  void fillTestData(bool isChecked) {
    if (isChecked) {
      emailController.text = 'test@aly-h.com';
      passwordController.text = 'Test123\$\$';
    } else {
      emailController.clear();
      passwordController.clear();
    }
    setState(() {});
  }

  Future<void> handleSubmit(GlobalStateNotifier globalStateNotifier) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
      errors = {};
    });

    try {
      final response = await http.post(
        Uri.parse('$API_URL/login'),
        body: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      final responseData = json.decode(response.body);

      if (responseData['status'] == 'error') {
        setState(() {
          errors = Map<String, List<String>>.from(responseData['errors']);
        });
      } else if (responseData['status'] == 'success') {
        // Handle success, store auth data, and navigate
        globalStateNotifier.updateGlobalState({
          'auth': responseData['data'],
          'status': 'auth',
          'selectedTabIndex': 0,
        });
      }
    } catch (e) {
      setState(() {
        errors['form'] = ['An error occurred. Please try again.'];
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Widget buildErrorText(String? error) {
    return error == null ? SizedBox.shrink() : InputError(errors: [error]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final globalStateNotifier =
            ref.read(globalStateNotifierProvider.notifier);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Login to Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildErrorText(errors['form']?.join(', ')),
              TextFormField(
                controller: emailController,
                onChanged: (_) => handleChange(),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  labelText: 'Email',
                  errorText: errors['email']?.join(', '),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value?.isEmpty == true
                    ? 'Email is required'
                    : (!RegExp(r'\S+@\S+\.\S+').hasMatch(value ?? 'a@a.a')
                        ? 'Not valid email'
                        : null)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                onChanged: (_) => handleChange(),
                obscureText: !showPassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                  errorText: errors['password']?.join(', '),
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Password is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: emailController.text == 'test@aly-h.com' &&
                        passwordController.text == 'Test123\$\$',
                    onChanged: (value) => fillTestData(value ?? false),
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    tristate: emailController.text == 'test@aly-h.com',
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'For Test Only? (* Recommended to register to avoid data issues caused by other testers sharing the same test account.)',
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ForgotPassword();
                })),
                child: Text(
                  'Forgot the password?',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 19, 99, 165),
                      decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                buttonText: 'Login',
                buttonIcon: Icons.login,
                buttonOnPressed: () => handleSubmit(globalStateNotifier),
                isSubmitting: isSubmitting,
              ),
            ],
          ),
        );
      },
    );
  }
}
