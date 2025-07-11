import 'package:totem_frontend/auth_gate.dart';
import 'package:totem_frontend/services/api_service.dart';
import 'package:flutter/material.dart';

final baseUrl = 'http://localhost:5001'; // Base URL

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService(baseUrl);

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(apiService: apiService),
    );
  }
}
