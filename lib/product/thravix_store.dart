import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThravixStore extends ChangeNotifier {
  int count = 0;
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    count = prefs.getInt('count') ?? 0;
    notifyListeners();
  }
}
