import 'package:flutter/material.dart';
import 'package:totem_frontend/pay_screen.dart';
import 'package:totem_frontend/contactless_screen.dart';
import 'package:totem_frontend/services/api_service.dart';

class ManOrNfcScreen extends StatelessWidget {
  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;
  final ApiService apiService;

  static const String manualImage = '';
  static const String NFCImage = '';

  const ManOrNfcScreen({
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
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        centerTitle: true,
      ),
      body: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Manually insert card details page
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 80, top: 50),
                child: ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Image(
                      image: AssetImage('assets/images/pay_manual.png'),
                    ),
                  ),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PayScreen(
                              amount: amount,
                              duration: duration,
                              zone: zone,
                              plate: plate,
                              apiService: apiService,
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: 100),

            // Contactless payment page
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 80, top: 50),
                child: ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Image(
                      image: AssetImage('assets/images/pay_nfc.png'),
                    ),
                  ),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ContactlessScreen(
                              amount: amount,
                              duration: duration,
                              zone: zone,
                              plate: plate,
                              apiService: apiService,
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
