import 'package:expense_tracker/constants/layout_constants.dart';
import 'package:expense_tracker/layouts/partials/nav_items.dart';
import 'package:expense_tracker/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/global_state_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current state of the global state
    final globalState = ref.watch(globalStateNotifierProvider);
    // Get access to the GlobalStateNotifier to modify the state
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);

    globalStateNotifier.loadInitialState();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: globalState['isLight'] ? ThemeMode.light : ThemeMode.dark,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            screenInfo[globalState['status']]?[globalState['selectedTabIndex']]
                    ['label'] ??
                'Expense Tracker',
            style: TextStyle(
              color: globalState['isLight'] ? Colors.black : Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                globalState['isLight'] ? Icons.dark_mode : Icons.light_mode,
                color: globalState['isLight'] ? Colors.black : Colors.white,
              ),
              onPressed: () {
                globalStateNotifier
                    .updateGlobalState({'isLight': !globalState['isLight']});
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: globalState['isLight']
                      ? lightColorScheme.primary
                      : darkColorScheme.primary,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 16.0),
                child: screenInfo[globalState['status']]
                        ?[globalState['selectedTabIndex']]['widget'] ??
                    Home(),
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavItems(),
      ),
    );
  }
}
