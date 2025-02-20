import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/input_error.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateProfileInformationForm extends StatefulWidget {
  const UpdateProfileInformationForm({super.key, required this.globalState});

  final Map globalState;

  @override
  UpdateProfileInformationFormState createState() =>
      UpdateProfileInformationFormState();
}

class UpdateProfileInformationFormState
    extends State<UpdateProfileInformationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  Map _errors = {};

  final TextEditingController nameController = TextEditingController(text: '');
  final TextEditingController emailController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    nameController.text = widget.globalState['auth']['user']['name'];
    emailController.text = widget.globalState['auth']['user']['email'];
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _handleSubmit(
      Map globalState, GlobalStateNotifier globalStateNotifier, context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _errors = {};
      });

      try {
        final response = await http.put(
          Uri.parse('$API_URL/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
          },
          body: jsonEncode({
            'name': nameController.text,
            'email': emailController.text,
          }),
        );

        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          globalStateNotifier.updateGlobalState({
            'auth': {
              ...globalState['auth'],
              'user': data['data']['user'],
            },
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
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
                'Profile Information',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              InputError(errors: _errors['name']),
              SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              InputError(errors: _errors['email']),
              SizedBox(height: 24),
              PrimaryButton(
                buttonText: 'Update Profile',
                isSubmitting: _isSubmitting,
                buttonIcon: Icons.cached_rounded,
                buttonOnPressed: () =>
                    _handleSubmit(globalState, globalStateNotifier, context),
              ),
            ],
          ),
        ),
      );
    });
  }
}
