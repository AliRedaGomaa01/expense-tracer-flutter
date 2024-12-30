import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define a class to manage state with custom logic.
class GlobalStateNotifier extends StateNotifier<Map<String, dynamic>> {
  GlobalStateNotifier() : super(_initialState);

  static final Map<String, dynamic> _initialState = {
    'auth': {
      'token': {},
      'user': {},
    },
    'flashMsg': {
      'success': "",
      'error': "",
    },
  };

  Future<void> loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();

    final String? auth = prefs.getString('auth');

    print(auth);

    final Map authMap = auth != null
        ? jsonDecode(auth)
        : {
            'token': {},
            'user': {},
          };

    state = {
      ...state,
      'auth': authMap,
    };
  }

  Future<void> updateGlobalState(Map<String, dynamic> newState) async {
    state = {...state, ...newState};

    final prefs = await SharedPreferences.getInstance();

    prefs.setString('auth', jsonEncode(state['auth']));
  }
}

// Define a provider for the GlobalStateNotifier.
final globalStateNotifierProvider =
    StateNotifierProvider<GlobalStateNotifier, Map<String, dynamic>>(
  (ref) => GlobalStateNotifier(),
);
