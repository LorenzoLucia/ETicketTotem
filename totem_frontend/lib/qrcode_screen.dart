import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:totem_frontend/services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatelessWidget {
  final double amount;
  final double duration;
  final String zone;
  final String uid;
  final String? ticketId;
  final String? plate;
  final ApiService apiService;

  QRScreen({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    required this.uid,
    this.ticketId,
    this.plate,
    required this.apiService,
  });

  final baseUrl = 'http://172.20.10.2:5001'; // Base URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donwload your Ticket!'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            QrImageView(
              data: "$baseUrl/users/$uid/tickets/$ticketId/extend",
              size: 280,
            ),
            Text("$baseUrl/users/$uid/tickets/$ticketId/extend"),
          ],
        ),
      ),
    );
  }
}
