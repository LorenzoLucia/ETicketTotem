import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:totem_frontend/services/api_service.dart';

class ContactlessScreen extends StatefulWidget {
  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;
  final ApiService apiService;

  ContactlessScreen({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
    required this.apiService,
  });

  @override
  _ContactlessScreenState createState() => _ContactlessScreenState();
}

class _ContactlessScreenState extends State<ContactlessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: Container(),
    );
  }
}
