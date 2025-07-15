import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:async';
import 'package:totem_frontend/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:totem_frontend/qrcode_screen.dart';

enum PaymentStatus { waiting, processing, success, failed }

class ContactlessScreen extends StatefulWidget {
  final double amount;
  final double duration;
  final String zone;
  final String uid;
  final String? plate;
  final ApiService apiService;

  ContactlessScreen({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    required this.uid,
    this.plate,
    required this.apiService,
  });

  @override
  _ContactlessScreenState createState() => _ContactlessScreenState();
}

class _ContactlessScreenState extends State<ContactlessScreen>
    with TickerProviderStateMixin {
  PaymentStatus _paymentStatus = PaymentStatus.waiting;
  WebSocketChannel? _channelWS;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _timeoutTimer;
  String? _errorMessage;

  String? ticketId;
  String? startTime;
  String? endTime;

  bool createdQrUrl = false;

  @override
  void initState() {
    super.initState();

    // Animazione per il simbolo di caricamento
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
    _readCardRFID();

    // Timeout Timer
    _timeoutTimer = Timer(const Duration(minutes: 1), () {
      if (_paymentStatus == PaymentStatus.waiting ||
          _paymentStatus == PaymentStatus.processing) {
        _handlePaymentTimeout();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _channelWS?.sink.close(status.goingAway);
    _timeoutTimer?.cancel();
    super.dispose();
  }

  String _hourAndMinuts(double parkingTime) {
    int parkingMinutes = (parkingTime * 60).toInt();
    String hours = (parkingTime.toInt()).toString().padLeft(2, '0');
    String minutes = (parkingMinutes % 60).toString().padLeft(2, '0');

    return '$hours:$minutes h';
  }

  void _readCardRFID() {
    try {
      final channelWS = WebSocketChannel.connect(
        Uri.parse('ws://172.20.10.3:9001/'),
      );

      channelWS.stream.listen(
        (rfidData) {
          rfidData = rfidData.toString();
          print(rfidData);
          if (rfidData.contains("CARTA VALIDA")) {
            setState(() {
              _paymentStatus = PaymentStatus.processing;
            });
            print("Processo il pagamento");
            _processPayment();
          } else if (rfidData.contains("CARTA NON VALIDA")) {
            setState(() {
              _paymentStatus = PaymentStatus.failed;
              _errorMessage = 'Invalid card. Please try again';
            });
          } else {
            setState(() {
              _paymentStatus = PaymentStatus.failed;
              _errorMessage = 'Invalid card. Please try again';
            });
          }
        },

        onError: (error) {
          print('WebSocket Error: $error');
          setState(() {
            _paymentStatus = PaymentStatus.failed;
            _errorMessage =
                'Failed to connect to RFID reader. Please try again';
          });
        },

        onDone: () {
          channelWS.sink.close();
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Failed to connect to RFID websocket: $e');
      setState(() {
        _paymentStatus = PaymentStatus.failed;
        _errorMessage = 'Failed to connect to RFID websocket';
      });
    }
  }

  Future<void> _processPayment() async {
    try {
      final methodId = dotenv.env["TOTEM_PAYMENT_METHOD_ID"];
      final (success, _ticketId, _startTime, _endTime) = await widget.apiService
          .payTicket(
            widget.plate ?? '',
            methodId ?? '',
            widget.amount.toString(),
            widget.duration.toString(),
            widget.zone,
            widget.uid,
          );
      if (success) {
        setState(() {
          _paymentStatus = PaymentStatus.success;
          ticketId = _ticketId;
          startTime = _startTime;
          endTime = _endTime;
        });
      } else {
        setState(() {
          _paymentStatus = PaymentStatus.failed;
          _errorMessage = 'Error processing payment. Please try again';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error processing payment: $e')));
    }
  }

  Future<void> _createQrUrl() async {
    // create strings for ticket
    final String zoneStr = widget.zone.substring(4);
    var durationStr = _hourAndMinuts(widget.duration);
    var amountStr = widget.amount.toStringAsFixed(2);
    amountStr = "$amountStr €";

    try {
      final success = await widget.apiService.createTicketSvg(
        startTime ?? '',
        endTime ?? '',
        durationStr,
        zoneStr,
        amountStr,
        ticketId ?? '',
      );
      if (success) {
        setState(() {
          createdQrUrl = true;
        });
      } else {
        setState(() {
          createdQrUrl = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating QR code payment: $e')),
      );
    }
  }

  void _handlePaymentTimeout() {
    setState(() {
      _paymentStatus = PaymentStatus.failed;
      _errorMessage = 'Timeout error. Please try again';
    });
  }

  void _retryPayment() {
    setState(() {
      _paymentStatus = PaymentStatus.waiting;
      _errorMessage = null;
    });

    _readCardRFID();
    _animationController.repeat(reverse: true);

    // Reset timeout timer
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(minutes: 5), () {
      if (_paymentStatus == PaymentStatus.waiting ||
          _paymentStatus == PaymentStatus.processing) {
        _handlePaymentTimeout();
      }
    });
  }

  Widget _buildStatusIcon() {
    switch (_paymentStatus) {
      case PaymentStatus.waiting:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: const Icon(
                  Icons.contactless,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
            );
          },
        );

      case PaymentStatus.processing:
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(color: Colors.orange, width: 3),
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );

      case PaymentStatus.success:
        return Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Icon(Icons.check, size: 50, color: Colors.white),
        );

      case PaymentStatus.failed:
        return Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: const Icon(Icons.close, size: 50, color: Colors.white),
        );
    }
  }

  String _getStatusMessage() {
    switch (_paymentStatus) {
      case PaymentStatus.waiting:
        return 'Please hold the credit card near the reader';
      case PaymentStatus.processing:
        return 'Processing payment...';
      case PaymentStatus.success:
        return 'Payment Successful!';
      case PaymentStatus.failed:
        return _errorMessage ?? 'Payment Failed. Please try again.';
    }
  }

  Color _getStatusColor() {
    switch (_paymentStatus) {
      case PaymentStatus.waiting:
        return Colors.blue;
      case PaymentStatus.processing:
        return Colors.orange;
      case PaymentStatus.success:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactless payment'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: _paymentStatus != PaymentStatus.processing,
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Informazioni pagamento
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount to Pay:', style: TextStyle(fontSize: 18)),
                        Text(
                          '€ ${widget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duration:', style: TextStyle(fontSize: 16)),
                        Text(
                          _hourAndMinuts(widget.duration),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Zone:', style: TextStyle(fontSize: 16)),
                        Text(
                          widget.zone,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plate:', style: TextStyle(fontSize: 16)),
                        Text(
                          widget.plate!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Spacer(),
            // RFID Status Icon
            _buildStatusIcon(),
            Spacer(),

            // Messaggio stato
            Text(
              _getStatusMessage(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
              textAlign: TextAlign.center,
            ),

            Spacer(),

            // Retry payment if it failed
            if (_paymentStatus == PaymentStatus.failed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _retryPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("Retry", style: TextStyle(fontSize: 16)),
                ),
              ),
            ] else if (_paymentStatus == PaymentStatus.success) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _createQrUrl();
                    createdQrUrl
                        ? {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => QRScreen(
                                    ticketId: ticketId,
                                    apiService: widget.apiService,
                                  ),
                            ),
                          ),
                        }
                        : null;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Continue to your ticket!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
