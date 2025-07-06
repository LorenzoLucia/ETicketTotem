import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:totem_frontend/services/api_service.dart';

class QRScreen extends StatelessWidget {
  final double amount;
  final double duration;
  final String zone;
  final String? id;
  final String? plate;
  final ApiService apiService;

  QRScreen({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Extend your Parking Ticket!')),
      body: Padding(padding: const EdgeInsets.all(16.0), child: Column()),
    );
  }
}
