import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/global_state_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get access to the GlobalStateNotifier to modify the state
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);

    globalStateNotifier.loadInitialState();

    return MaterialApp(
      home: TestScreen(),
    );
  }
}

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current state of the global state
    final globalState = ref.watch(globalStateNotifierProvider);
    // Get access to the GlobalStateNotifier to modify the state
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Global State Test Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current State:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Display the current global state
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  globalState.toString(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Button to modify the global state
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Update the global state when the button is pressed
                  globalStateNotifier.updateGlobalState({
                    'auth': {
                      'user': {'name': 'John Doe'},
                      'token': {
                        'text': '',
                        'expires_at':
                            DateTime.now().add(Duration(days: 1)).toString(),
                      },
                    }
                  });
                },
                child: Text('Update State'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
