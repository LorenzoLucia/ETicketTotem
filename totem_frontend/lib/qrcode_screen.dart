import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:totem_frontend/services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatelessWidget {
  final double amount;
  final double duration;
  final String zone;
  final String? ticketId;
  final String? plate;
  final ApiService apiService;

  QRScreen({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.ticketId,
    this.plate,
    required this.apiService,
  });

  final baseUrl = 'http://172.20.10.2:5001'; // Base URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extend your Parking Ticket!'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: QrImageView(data: "$baseUrl/extend_ticket/$ticketId", size: 280),
      ),
    );
  }
}
