import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_frontend/contactless_screen.dart';
import 'package:totem_frontend/services/api_service.dart';
import 'package:totem_frontend/wheel_time_picker_widget.dart';
import 'package:virtual_keyboard_custom_layout/virtual_keyboard_custom_layout.dart';

class TotemInputScreen extends StatefulWidget {
  final ApiService apiService;
  final String uid;
  const TotemInputScreen({
    super.key,
    required this.apiService,
    required this.uid,
  });

  @override
  State<TotemInputScreen> createState() => _TotemInputScreenState();
}

class _TotemInputScreenState extends State<TotemInputScreen> {
  // ignore: unused_field
  static const double fontSizeLarge = 18;
  static const double containerHeight = 40;
  static const double paddingSize = 7;
  final TextEditingController plateController = TextEditingController();
  final FocusNode zoneFocusNode = FocusNode();

  DateTime now = DateTime.now();

  String? plate;
  String? selectedZone;
  Map<String, double> zonePrices = {};
  int parkingTimeHours = 1; // Default to 1 hour parking time
  int parkingTimeMinutes = 0; // Default to 0 minutes
  double tikcetPrice = 0.0;

  // Variable for keyboard
  var isKeyboardVisible = false;
  final List<List<dynamic>>? keyLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', "BACKSPACE"],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', "RETURN"],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  OverlayEntry? entry;

  void _showKeyboard() {
    entry = OverlayEntry(
      builder:
          (context) => Positioned(
            height: 180,
            width: MediaQuery.of(context).size.width,
            bottom: 0,
            child: VirtualKeyboard(
              textController: plateController,
              height: 180,
              width: double.infinity,
              fontSize: fontSizeLarge,
              type: VirtualKeyboardType.Custom,
              keys: keyLayout,
              onKeyPress: _onKeyPress,
            ),
          ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  void _hideKeyboard() {
    entry!.remove();
  }

  void _saveTextValues() {
    setState(() {
      plateController.text == ''
          ? plate = null
          : plate = plateController.text.trim();
    });
  }

  void _onKeyPress(VirtualKeyboardKey key) {
    if (key.action == VirtualKeyboardKeyAction.Return) {
      _hideKeyboard();
    }
  }

  @override
  void initState() {
    super.initState();
    loadPrices();
    // Start listening to changes.
    plateController.addListener(_saveTextValues);
    zoneFocusNode.addListener(() {
      if (zoneFocusNode.hasFocus) {
        _hideKeyboard();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    plateController.dispose();
    zoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadPrices() async {
    try {
      final prices = await widget.apiService.fetchZonePrices();
      print('Zone prices loaded: $prices');
      setState(() {
        zonePrices = prices;
      });
    } catch (e) {
      // Handle error
      print('Error loading zones: $e');
    }
  }

  void calculatePrice() {
    if (selectedZone != null) {
      setState(() {
        tikcetPrice = double.parse(
          (zonePrices[selectedZone]! *
                  (parkingTimeHours + parkingTimeMinutes / 60))
              .toStringAsFixed(1),
        );
      });
    }
  }

  String calculateTicketEndTime() {
    DateTime now = DateTime.now();
    DateTime date = now.add(
      Duration(hours: parkingTimeHours, minutes: parkingTimeMinutes),
    );
    Map<int, String> months = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December",
    };

    String month = months[date.month]!;
    int day = date.day;
    int hour = date.hour;
    int minutes = date.minute;

    return '$day of $month at ${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          isKeyboardVisible = false;
        });
        _hideKeyboard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Ticket Details'),
          centerTitle: true,
        ),
        body: Column(
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
                                'Enter Plate',
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
                              keyboardType: TextInputType.none,
                              controller: plateController,
                              onTap: () {
                                setState(() {
                                  isKeyboardVisible = true;
                                });
                                _showKeyboard();
                              },
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

                      // Zone
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
                                'Select Zone',
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
                            child: DropdownButton<String>(
                              focusNode: zoneFocusNode,
                              padding: EdgeInsets.only(left: paddingSize),
                              value: selectedZone,
                              style: const TextStyle(
                                fontSize: fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                              hint: Text('Zone'),
                              items:
                                  zonePrices.keys.map((zone) {
                                    double zonePrice = zonePrices[zone]!;
                                    return DropdownMenuItem<String>(
                                      value: zone,
                                      child: Text("$zone -  $zonePrice €/hr"),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedZone = value;
                                  calculatePrice();
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      Spacer(),

                      // Parking Time
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
                                'Select End Time',
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
                              onTimeChanged: (Duration value) {
                                setState(() {
                                  parkingTimeHours = value.inHours;
                                  parkingTimeMinutes = value.inMinutes
                                      .remainder(60);
                                });
                                calculatePrice();
                              },
                            ),
                          ),
                        ],
                      ),

                      Spacer(),

                      // Parking Time
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
                                'Ticket Expiration Date',
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
                            child: Padding(
                              padding: EdgeInsets.all(paddingSize),
                              child: Text(
                                calculateTicketEndTime(),
                                style: const TextStyle(
                                  fontSize: fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
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
                            plate != null &&
                                    selectedZone != null &&
                                    (parkingTimeHours +
                                            parkingTimeMinutes / 60) !=
                                        0
                                ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ContactlessScreen(
                                            amount: tikcetPrice,
                                            duration:
                                                parkingTimeHours +
                                                parkingTimeMinutes / 60,
                                            zone: selectedZone!,
                                            plate: plate!,
                                            uid: widget.uid,
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
                          'Proceed To Payment',
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
