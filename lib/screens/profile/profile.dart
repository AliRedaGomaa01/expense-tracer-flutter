import 'package:expense_tracker/providers/global_state_provider.dart';
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

      return Center(
        child: CustomOutlinedButton(
          buttonText: 'Logout',
          buttonIcon: Icons.logout_outlined,
          buttonOnPressed: globalStateNotifier.logout,
        ),
      );
    });
  }
}
