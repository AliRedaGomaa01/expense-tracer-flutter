import 'dart:convert';
import 'package:expense_tracker/utils/sqflite_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalStateNotifier extends StateNotifier<Map<String, dynamic>> {
  GlobalStateNotifier() : super(_initialState);

  static final Map<String, dynamic> _initialState = {
    'auth': {
      'token': <String, dynamic>{},
      'user': <String, dynamic>{},
    },
    'flashMsg': {
      'success': "",
      'error': "",
    },
    'status': 'guest',
    'selectedTabIndex': 0,
    'isLight': false,
  };

  Future<void> loadInitialState() async {
    final db = KeyValueDatabase();
    final String? cachedGlobalState = await db.getValue('globalState');

    state =
        cachedGlobalState != null ? jsonDecode(cachedGlobalState) : {...state};

    if (cachedGlobalState != null &&
        state['auth']['token'] != {} &&
        state['auth']['token']['expires_at'] != null) {
      final String tokenExpiry = state['auth']['token']['expires_at'];
      final DateTime tokenExpiryDateTime = DateTime.parse(tokenExpiry);
      final DateTime currentTime = DateTime.now();
      if (currentTime.isAfter(tokenExpiryDateTime)) {
        logout();
      }
    }
  }

  Future<void> updateGlobalState(Map<String, dynamic> newState) async {
    state = {...state, ...newState};

    final db = KeyValueDatabase();
    await db.setValue('globalState', jsonEncode(state));
  }

  Future<void> logout() async {
    await updateGlobalState({
      'auth': {
        'token': {},
        'user': {},
      },
      'status': 'guest',
      'selectedTabIndex': 0,
    });
  }
}

final globalStateNotifierProvider =
    StateNotifierProvider<GlobalStateNotifier, Map<String, dynamic>>(
  (ref) => GlobalStateNotifier(),
);

/*
    // Watch the current state of the global state
    final globalState = ref.watch(globalStateNotifierProvider);
    // Get access to the GlobalStateNotifier to modify the state
    final globalStateNotifier = ref.read(globalStateNotifierProvider.notifier);
*/
