import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseAuth.instance.signOut();
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  print('Cache limpo!');
}
