import 'package:expense_tracker/providers/global_state_provider.dart';
import 'package:expense_tracker/screens/profile/partials/delete_user_form.dart';
import 'package:expense_tracker/screens/profile/partials/update_password_form.dart';
import 'package:expense_tracker/screens/profile/partials/update_profile_information_form.dart';
import 'package:expense_tracker/shared_widgets/custom_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      // Watch the current state of the global state
      final globalState = ref.watch(globalStateNotifierProvider);
      // Get access to the GlobalStateNotifier to modify the state
      final globalStateNotifier =
          ref.read(globalStateNotifierProvider.notifier);

      final formContainerDecoration = BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary.withAlpha(100),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: Colors.grey, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      );

      return Column(
        children: [
          CustomOutlinedButton(
            buttonText: 'Logout',
            buttonIcon: Icons.logout_outlined,
            buttonOnPressed: globalStateNotifier.logout,
          ),
          SizedBox(height: 32),
          Container(
            decoration: formContainerDecoration,
            padding: EdgeInsets.all(16.0),
            child: UpdateProfileInformationForm(globalState: globalState),
          ),
          SizedBox(height: 32),
          Container(
            decoration: formContainerDecoration,
            padding: EdgeInsets.all(16),
            child: UpdatePasswordForm(),
          ),
          SizedBox(height: 32),
          Container(
            decoration: formContainerDecoration,
            padding: EdgeInsets.all(16),
            child: DeleteUserForm(),
          ),
        ],
      );
    });
  }
}
