import 'package:firebase_core/firebase_core.dart';
import 'package:first_firebase_project/app.dart';
import 'package:first_firebase_project/firebase_options.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MovieApp());
}

