import 'package:flutter/material.dart';
import 'package:totem_frontend/services/api_service.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatefulWidget {
  final String? ticketId;
  final ApiService apiService;

  QRScreen({super.key, this.ticketId, required this.apiService});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final gitUrl =
      "https://raw.githubusercontent.com/LorenzoLucia/ETicketTotem/refs/heads/main/ticket_files";
  Timer? _endTimer;

  @override
  void initState() {
    super.initState();
    _endTimer = Timer(const Duration(seconds: 60), () {
      _endTicketPurchase();
    });
  }

  @override
  void dispose() {
    _endTimer?.cancel();
    super.dispose();
  }

  void _endTicketPurchase() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  QrCode _createQrCode() {
    return QrCode(6, QrErrorCorrectLevel.L)
      ..addData("$gitUrl/${widget.ticketId}.svg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save your E-Ticket'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            QrImageView.withQr(qr: _createQrCode(), size: 300),

            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _endTicketPurchase();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("Done", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
