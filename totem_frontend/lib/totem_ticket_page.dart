import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_frontend/man_or_nfc_screen.dart';
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
  final TextEditingController plateController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();

  DateTime now = DateTime.now();

  String? plate;
  String? zone;
  double parkingTime = 0; // Default to 0
  double tikcetPrice = 0.0;

  // Fixed zone and price
  final double fixedZonePrice = 2.0;

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    plateController.addListener(_saveTextValues);
    zoneController.addListener(_saveTextValues);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    zoneController.dispose();
    plateController.dispose();
    super.dispose();
  }

  void calculatePrice() {
    tikcetPrice = double.parse(
      (fixedZonePrice * parkingTime).toStringAsFixed(1),
    );
  }

  void _saveTextValues() {
    setState(() {
      plateController.text == '' ? plate = null : plate = plateController.text;
      zoneController.text == '' ? zone = null : zone = zoneController.text;
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
                              controller: plateController,
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
                              // onTapOutside: (event) {
                              //   FocusManager.instance.primaryFocus?.unfocus();
                              //   plate = plateController.text;
                              //   // print('onTapOutside');
                              //   // print(plate);
                              // },
                              // onEditingComplete: () {
                              //   plate = plateController.text;
                              // },
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
                              controller: zoneController,
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
                              // onTapOutside: (event) {
                              //   FocusManager.instance.primaryFocus?.unfocus();
                              //   zone = zoneController.text;
                              //   // print('onTapOutside');
                              //   // print(zone);
                              // },
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

                      // Testo Prezzo
                      Text(
                        'Price: \$${tikcetPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Spacer(),

                      // Pulsante di conferma
                      ElevatedButton(
                        onPressed:
                            plate != null && zone != null && parkingTime != 0
                                ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ManOrNfcScreen(
                                            amount: tikcetPrice,
                                            duration: parkingTime,
                                            zone: zone!,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
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
