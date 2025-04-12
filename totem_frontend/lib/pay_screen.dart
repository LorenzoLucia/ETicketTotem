import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:totem_frontend/services/api_service.dart';

class PayScreen extends StatefulWidget {
  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;
  final ApiService apiService;

  const PayScreen({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
    required this.apiService,
  });

  @override
  PayScreenState createState() => PayScreenState();
}

class PayScreenState extends State<PayScreen> {
  PayScreenState(); // Add an unnamed constructor
  WebSocketChannel? channel;
  StreamController<String>? streamController;
  bool paymentFailed = false;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:9001'));
    streamController = StreamController<String>();
    channel?.stream.listen(
      (message) {
        print('Received message: $message');
        if (message.isNotEmpty) {
          streamController?.add(message);
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _showPaymentFailedDialog();
      },
      onDone: () {
        print('WebSocket connection closed');
        if (paymentFailed) {
          _showPaymentFailedDialog();
        }
      },
    );

    setState(() {
      paymentFailed = false; // Reset paymentFailed
    });

    Future.delayed(Duration(seconds: 45), () {
      if (!paymentFailed) {
        print('Timeout 45s: No RFID detected');
        _showPaymentFailedDialog();
      }
    });
  }

  Future<void> _sendPaymentData(String rfid) async {
    final url = Uri.parse('https://your-server-url.com/api/payments');
    final payload = {
      'amount': widget.amount,
      'duration': widget.duration,
      'zone': widget.zone,
      'id': widget.id,
      'plate': widget.plate,
      'rfid': rfid,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Payment data sent successfully');
        if (mounted) {
          Navigator.pop(context); // Go back to the previous screen
        }
      } else {
        print('Failed to send payment data: ${response.statusCode}');
        // _showPaymentFailedDialog();
        if (mounted) {
          Navigator.pop(context); // Go back to the previous screen
        }
      }
    } catch (e) {
      print('Error sending payment data: $e');
      // _showPaymentFailedDialog();
      if (mounted) {
          Navigator.pop(context); // Go back to the previous screen
        }
    }
  }

  void _showPaymentFailedDialog() {
    setState(() {
      paymentFailed = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text('Do you want to retry or go back to the home page?'),
        actions: [
          TextButton(
            onPressed: () {
              // Reset paymentFailed
              Navigator.pop(context); // Close the dialog
              _connectToWebSocket(); // Retry
            },
            child: Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context); // Go back to the home page
            },
            child: Text('Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
    child: paymentFailed
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Payment Failed. Please try again.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: (){ // Reset paymentFailed
                  _connectToWebSocket();
                },
                child: Text('Retry'),
              ),
            ],
          )
        : StreamBuilder(
            stream: streamController?.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final payload = snapshot.data as String;

                if (payload.isNotEmpty) {
                  
                  // _sendPaymentData(payload);
                    Future.delayed(Duration(seconds: 5), () {
                    if (mounted) {
                      Navigator.pop(context); // Go back to the previous screen
                    }
                    });

                    return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                      'Payment Succeed!',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Icon(Icons.check_circle,
                        color: Colors.green, size: 48),
                    ],
                    );
                }
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Amount to Pay: \$${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please pay using your RFID card.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 32),
                  CircularProgressIndicator(), // Indicate waiting for RFID payment
                ],
              );
            },
          ),
      )
    );
  }

  @override
  void dispose() {
    setState(() {
      paymentFailed = true; // Cancel the timer by marking payment as failed
    });// Cancel the timer by marking payment as failed
    streamController?.close();
    channel?.sink.close(status.goingAway);
    super.dispose();
  }
}
