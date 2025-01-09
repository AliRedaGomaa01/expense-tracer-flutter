import 'package:expense_tracker/constants/layout_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';

class NavItems extends ConsumerWidget {
  const NavItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalStateNotifierProvider);
    // Get access to the GlobalStateNotifier to modify the state
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);

    void selectPage(int index) {
      globalStateNotifier.updateGlobalState({'selectedTabIndex': index});
    }

    return BottomNavigationBar(
      onTap: selectPage,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor:
          Theme.of(context).colorScheme.onSurface.withAlpha(100),
      selectedItemColor: Theme.of(context).colorScheme.onSurface,
      currentIndex: globalState['selectedTabIndex'] ?? 0,
      items: [
        BottomNavigationBarItem(
          icon: screenInfo[globalState['status']]?[0]['icon'],
          label: screenInfo[globalState['status']]?[0]['label'],
        ),
        BottomNavigationBarItem(
          icon: screenInfo[globalState['status']]?[1]['icon'],
          label: screenInfo[globalState['status']]?[1]['label'],
        ),
        BottomNavigationBarItem(
          icon: screenInfo[globalState['status']]?[2]['icon'],
          label: screenInfo[globalState['status']]?[2]['label'],
        ),
      ],
    );
  }
}
