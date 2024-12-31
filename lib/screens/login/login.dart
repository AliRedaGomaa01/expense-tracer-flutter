import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  bool showPassword = false;
  bool isSubmitting = false;
  Map<String, List<String>> errors = {};

  void handleChange() {
    if (errors != {}) {
      setState(() {
        errors = {};
      });
    }
  }

  Map<String, List<String>> validate() {
    final Map<String, List<String>> validationErrors = {};

    if (emailController.text.isEmpty) {
      validationErrors['email'] = ['Email is required'];
    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(emailController.text)) {
      validationErrors['email'] = ['Invalid email address'];
    }

    if (passwordController.text.isEmpty) {
      validationErrors['password'] = ['Password is required'];
    }

    return validationErrors;
  }

  void fillTestData(bool isChecked) {
    if (isChecked) {
      emailController.text = 'test@aly-h.com';
      passwordController.text = 'Test123\$\$';
    } else {
      emailController.clear();
      passwordController.clear();
    }
  }

  Future<void> handleSubmit(GlobalStateNotifier globalStateNotifier) async {
    final validationErrors = validate();
    if (validationErrors.isNotEmpty) {
      setState(() {
        errors = validationErrors;
      });
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Consumer(
          builder: (context, ref, child) {
            // final globalState = ref.watch(globalStateNotifierProvider);
            final globalStateNotifier =
                ref.read(globalStateNotifierProvider.notifier);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login to Your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (errors['form'] != null)
                    Text(
                      errors['form']!.join(', '),
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextFormField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    onChanged: (_) => handleChange(),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      errorText: errors['email']?.join(', '),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Text('Password',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    onChanged: (_) => handleChange(),
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      errorText: errors['password']?.join(', '),
                      suffixIcon: IconButton(
                        icon: Icon(showPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: emailController.text == 'test@aly-h.com' &&
                            passwordController.text == 'Test123\$\$',
                        onChanged: (value) => fillTestData(value ?? false),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'For Test Only? (* Recommended to register to avoid data issues caused by other testers sharing the same test account.)',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                    child: Text(
                      'Forgot the password?',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            handleSubmit(globalStateNotifier);
                          },
                    child: Text(isSubmitting ? 'Submitting...' : 'Login'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
