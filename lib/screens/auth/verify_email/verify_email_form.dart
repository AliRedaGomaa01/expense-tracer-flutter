import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyEmailForm extends StatefulWidget {
  const VerifyEmailForm({super.key, required this.ref});
  final WidgetRef ref;
  @override
  VerifyEmailFormState createState() => VerifyEmailFormState();
}

class VerifyEmailFormState extends State<VerifyEmailForm> {
  final _formKey = GlobalKey<FormState>();
  String? _token;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final globalState = widget.ref.watch(globalStateNotifierProvider);
      final globalStateNotifier =
          widget.ref.read(globalStateNotifierProvider.notifier);

      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse('$API_URL/verify-email'),
          headers: {
            'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
            'Content-Type': 'application/json',
          },
          body: json.encode({'token': _token}),
        );

        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          globalStateNotifier.updateGlobalState({
            'selectedTabIndex': 0,
            'auth': {
              'token': globalState['auth']['token'],
              "user": responseData['data']['user'],
            },
          });
        } else if (responseData['status'] == 'Unauthenticated') {
          globalStateNotifier.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have been logged out.'),
            ),
          );
        } else {
          print(responseData.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred. Please try again later.'),
            ),
          );
          setState(() {
            _errorMessage = 'Invalid verification code. Please try again.';
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Token Code',
              hintText: 'Enter the received token  ',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the verification code';
              }
              return null;
            },
            onSaved: (value) {
              _token = value;
            },
          ),
          SizedBox(height: 16),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          SizedBox(height: 16),
          PrimaryButton(
            buttonIcon: Icons.done,
            buttonText: 'Verify Email',
            buttonOnPressed: _submitForm,
            isSubmitting: _isSubmitting,
          ),
        ],
      ),
    );
  }
}
