import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_frontend/pay_screen.dart';
import 'package:totem_frontend/services/api_service.dart';
import 'package:totem_frontend/wheel_time_picker_widget.dart';

class LicensePlateInputScreen extends StatefulWidget {
  final ApiService apiService;
  const LicensePlateInputScreen({super.key, required this.apiService});

  @override
  State<LicensePlateInputScreen> createState() =>
      _LicensePlateInputScreenState();
}

class _LicensePlateInputScreenState extends State<LicensePlateInputScreen> {
  // ignore: unused_field
  static const double fontSizeRegular = 16;
  static const double fontSizeLarge = 18;
  static const double containerHeight = 40;
  static const double paddingSize = 7;

  DateTime now = DateTime.now();

  String? plate;
  double parkingTime = 1; // Default to 1 hour
  double price = 0.0;

  // Fixed zone and price
  final String fixedZone = 'Zone A';
  final double fixedZonePrice = 2.0;

  void calculatePrice() {
    setState(() {
      price = fixedZonePrice * parkingTime / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insert Ticket Data'),
        centerTitle: true,
      ),
      body: GestureDetector(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Testo Targa
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(paddingSize),
                              child: Text(
                                'Plate',
                                style: const TextStyle(
                                  fontSize: fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 20),

                          Container(
                            width: 200,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(paddingSize),
                                hintText: 'Insert Plate',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Spacer(),

                      // Testo Zona
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(paddingSize),
                              child: Text(
                                'Zone',
                                style: const TextStyle(
                                  fontSize: fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 20),

                          Container(
                            width: 200,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(paddingSize),
                                hintText: 'Insert Zone',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Spacer(),

                      // Testo Tempo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(paddingSize),
                              child: Text(
                                'End Time',
                                style: const TextStyle(
                                  fontSize: fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 20),

                          Container(
                            width: 200,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TimePickerTextField(
                              initialTime: Duration(
                                hours: now.hour,
                                minutes: now.minute,
                              ),
                              onTimeChanged: (double value) {
                                setState(() {
                                  parkingTime = value;
                                });
                                calculatePrice();
                              },
                            ),
                          ),
                        ],
                      ),

                      Spacer(),

                      Spacer(),

                      // Testo Prezzo
                      Text(
                        'Price: \$${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Spacer(),

                      // Pulsante di conferma
                      ElevatedButton(
                        onPressed:
                            plate != null
                                ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PayScreen(
                                            amount: price,
                                            duration: (parkingTime * 2).toInt(),
                                            zone: fixedZone,
                                            plate: plate!,
                                            apiService: widget.apiService,
                                          ),
                                    ),
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Conferma',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
