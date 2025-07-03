import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'dart:async';
import 'package:totem_frontend/services/api_service.dart';

enum PaymentStatus { waiting, processing, success, failed }

class ContactlessScreen extends StatefulWidget {
  final double amount;
  final double duration;
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

class _ContactlessScreenState extends State<ContactlessScreen>
    with TickerProviderStateMixin {
  PaymentStatus _paymentStatus = PaymentStatus.waiting;
  WebSocketChannel? _channel;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _timeoutTimer;
  String? _errorMessage;

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

    // Avvia la connessione WebSocket
    _connectToRFIDReader();

    // Timer di timeout per evitare attese infinite
    _timeoutTimer = Timer(const Duration(minutes: 5), () {
      if (_paymentStatus == PaymentStatus.waiting ||
          _paymentStatus == PaymentStatus.processing) {
        _handlePaymentTimeout();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _channel?.sink.close(status.goingAway);
    _timeoutTimer?.cancel();
    super.dispose();
  }

  String _hourAndMinuts(double parkingTime) {
    int parkingMinutes = (parkingTime * 60).toInt();
    String hours = (parkingTime.toInt()).toString().padLeft(2, '0');
    String minutes = (parkingMinutes % 60).toString().padLeft(2, '0');

    return '$hours:$minutes h';
  }

  void _connectToRFIDReader() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:9001'));

      _channel!.stream.listen(
        (data) {
          _handleRFIDData(data);
        },
        onError: (error) {
          print('WebSocket Error: $error');
          setState(() {
            _paymentStatus = PaymentStatus.failed;
            _errorMessage = 'Failed to connect to RFID reader';
          });
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );

      // Invia messaggio per iniziare la lettura RFID
      _channel!.sink.add(
        json.encode({'action': 'start_reading', 'amount': widget.amount}),
      );
    } catch (e) {
      print('Failed to connect to RFID reader: $e');
      setState(() {
        _paymentStatus = PaymentStatus.failed;
        _errorMessage = 'Failed to connect to RFID reader';
      });
    }
  }

  void _handleRFIDData(dynamic data) {
    try {
      final Map<String, dynamic> rfidData = json.decode(data);

      if (rfidData['status'] == 'card_detected') {
        setState(() {
          _paymentStatus = PaymentStatus.processing;
        });

        // Processa il pagamento
        _processPayment();
      } else if (rfidData['status'] == 'error') {
        setState(() {
          _paymentStatus = PaymentStatus.failed;
          _errorMessage = rfidData['message'] ?? 'Error reading card';
        });
      }
    } catch (e) {
      print('Error parsing RFID data: $e');
      setState(() {
        _paymentStatus = PaymentStatus.failed;
        _errorMessage = 'Error reading card details';
      });
    }
  }

  Future<void> _processPayment() async {
    return;
    // try {
    //   // Chiamata API per processare il pagamento con Stripe
    //   final response = await widget.apiService.post('/payments/contactless', {
    //     'amount': (widget.amount * 100).round(), // Stripe usa centesimi
    //     'currency': 'eur',
    //     'card_data': cardData,
    //     'duration': widget.duration,
    //     'zone': widget.zone,
    //     'plate': widget.plate,
    //     'parking_id': widget.id,
    //     'payment_method_types': ['card_present'],
    //     'capture_method': 'automatic',
    //   });

    //   if (response.statusCode == 200) {
    //     final Map<String, dynamic> paymentResult = json.decode(response.body);

    //     if (paymentResult['status'] == 'succeeded') {
    //       setState(() {
    //         _paymentStatus = PaymentStatus.success;
    //       });

    //       // Mostra snackbar di successo
    //       _showSuccessSnackBar();

    //       // Torna alla schermata precedente dopo 3 secondi
    //       Timer(const Duration(seconds: 3), () {
    //         Navigator.of(context).pop(true); // true indica successo
    //       });
    //     } else {
    //       setState(() {
    //         _paymentStatus = PaymentStatus.failed;
    //         _errorMessage =
    //             paymentResult['error']?['message'] ?? 'Pagamento fallito';
    //       });
    //     }
    //   } else {
    //     setState(() {
    //       _paymentStatus = PaymentStatus.failed;
    //       _errorMessage = 'Errore server: ${response.statusCode}';
    //     });
    //   }
    // } catch (e) {
    //   print('Payment processing error: $e');
    //   setState(() {
    //     _paymentStatus = PaymentStatus.failed;
    //     _errorMessage = 'Errore processamento pagamento';
    //   });
    // }
  }

  void _handlePaymentTimeout() {
    setState(() {
      _paymentStatus = PaymentStatus.failed;
      _errorMessage = 'Timeout error';
    });
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _retryPayment() {
    setState(() {
      _paymentStatus = PaymentStatus.waiting;
      _errorMessage = null;
    });

    _animationController.repeat(reverse: true);
    _connectToRFIDReader();

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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: const Icon(
                  Icons.contactless,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
            );
          },
        );

      case PaymentStatus.processing:
        return Container(
          width: 120,
          height: 120,
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
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Icon(Icons.check, size: 60, color: Colors.white),
        );

      case PaymentStatus.failed:
        return Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: const Icon(Icons.close, size: 60, color: Colors.white),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Informazioni pagamento
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount to Pay:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '€ ${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration:', style: TextStyle(fontSize: 16)),
                        Text(
                          _hourAndMinuts(widget.duration),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Zone:', style: TextStyle(fontSize: 16)),
                        Text(
                          widget.zone,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (widget.plate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Plate:', style: TextStyle(fontSize: 16)),
                          Text(
                            widget.plate!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Icona stato pagamento
            // _buildStatusIcon(),

            // Payment button
            ElevatedButton(
              onPressed: () {
                _processPayment();
              },
              child: Text("Proceed To Payment"),
            ),

            const SizedBox(height: 24),

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

            const SizedBox(height: 10),

            // Istruzioni aggiuntive
            if (_paymentStatus == PaymentStatus.waiting)
              const Text(
                'Please hold the credit card near the reader',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

            const Spacer(),

            // Pulsanti azione
            if (_paymentStatus == PaymentStatus.failed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _retryPayment,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],

            if (_paymentStatus != PaymentStatus.processing)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _paymentStatus == PaymentStatus.success
                        ? 'Close'
                        : 'Cancel',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
