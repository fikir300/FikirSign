import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Screen { welcome, login, signup, home, translate, phrases, profile }

/// App-wide state: current screen + logged-in user (null = guest).
/// TODO(Person 2): replace local storage with Cognito + DynamoDB.
class AppState extends ChangeNotifier {
  Screen screen = Screen.welcome;
  Map<String, String>? user;
  late SharedPreferences _p;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    final raw = _p.getString('fikr-user');
    if (raw != null) {
      user = Map<String, String>.from(jsonDecode(raw));
      screen = Screen.home;
    }
  }

  void go(Screen s) {
    screen = s;
    notifyListeners();
  }

  Future<void> saveUser(Map<String, String>? u) async {
    user = u;
    if (u == null) {
      await _p.remove('fikr-user');
    } else {
      await _p.setString('fikr-user', jsonEncode(u));
    }
    notifyListeners();
  }
}
