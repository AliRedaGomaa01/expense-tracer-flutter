import 'package:expense_tracker/constants/api_constants.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/screens/auth/verify_email/verify_email_form.dart';
import 'package:expense_tracker/shared_widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyEmailFirst extends StatefulWidget {
  const VerifyEmailFirst({super.key, required this.ref});
  final WidgetRef ref;
  @override
  VerifyEmailFirstState createState() => VerifyEmailFirstState();
}

class VerifyEmailFirstState extends State<VerifyEmailFirst> {
  String? successMessage;
  bool isSubmitting = false;
  bool viewVerificationForm = false;
  bool emailIsSend = false;

  Future<void> handleResendLink() async {
    final globalState = widget.ref.watch(globalStateNotifierProvider);
    final globalStateNotifier =
        widget.ref.read(globalStateNotifierProvider.notifier);

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$API_URL/email/verification-notification'),
        headers: {
          'Authorization': 'Bearer ${globalState['auth']['token']['text']}',
        },
      );

      final responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        setState(() {
          successMessage =
              'Verification email has been sent to your email successfully.';
          emailIsSend = true;
        });
        Future.delayed(Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              successMessage = null;
            });
          }
        });
      } else if (responseData['status'] == 'Unauthenticated') {
        globalStateNotifier.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have been logged out.'),
          ),
        );
      } else {
        print(responseData['message']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later.'),
          ),
        );
      }
    } catch (err) {
      print(err);
    }

    setState(() {
      isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!viewVerificationForm) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Verify Your Email To Reach Protected Pages',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Please check your email to verify your account.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 8),
          Text(
            'If you haven\'t received the verification email, please check your spam folder.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 8),
          Text(
            'If you still haven\'t received the verification email, please click the "Resend Verification Email" button to send it again.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          if (successMessage == null || successMessage!.isEmpty)
            PrimaryButton(
              buttonIcon: Icons.email,
              buttonText: 'Resend Verification Email',
              buttonOnPressed: () => handleResendLink(),
              isSubmitting: isSubmitting,
            ),
          if (emailIsSend)
            PrimaryButton(
              buttonIcon: Icons.edit,
              buttonColor: const Color.fromARGB(255, 255, 250, 191),
              buttonText: 'Click if received email',
              buttonOnPressed: () => setState(() {
                viewVerificationForm = true;
              }),
            ),
          if (successMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                successMessage!,
                style: TextStyle(color: Colors.green),
              ),
            ),
        ],
      );
    } else {
      return VerifyEmailForm(ref: widget.ref);
    }
  }
}
