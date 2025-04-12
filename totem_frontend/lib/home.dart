import 'package:flutter/material.dart';
import 'package:totem_frontend/pay_screen.dart';
import 'package:totem_frontend/services/api_service.dart';

class TicketPage extends StatefulWidget {
  final ApiService apiService;
  const TicketPage({super.key, required this.apiService});

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  String? plate;
  int selectedTime = 1; // Default to 1 hour
  double price = 0.0;

  // Fixed zone and price
  final String fixedZone = 'Zone A';
  final double fixedZonePrice = 2.0;

  void calculatePrice() {
    setState(() {
      price = fixedZonePrice * selectedTime / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Zone: $fixedZone',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        plate = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your plate number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Select End Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'End Time: ${DateTime.now().add(Duration(hours: (selectedTime / 2).toInt())).hour}:${DateTime.now().add(Duration(hours: (selectedTime / 2).toInt(), minutes: 30 * (selectedTime % 2))).minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 16),
            ),
            Slider(
              value: selectedTime.toDouble(),
              min: 0,
              max: 46,
              divisions: 46,
              label:
                  '${DateTime.now().add(Duration(hours: (selectedTime / 2).toInt())).hour}:${DateTime.now().add(Duration(hours: (selectedTime / 2).toInt(), minutes: 30 * (selectedTime % 2))).minute.toString().padLeft(2, '0')}',
              onChanged: (value) {
                setState(() {
                  selectedTime = value.toInt();
                  calculatePrice();
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Price: \$${price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: plate != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PayScreen(
                              amount: price,
                              duration: selectedTime,
                              zone: fixedZone,
                              plate: plate!,
                              apiService: widget.apiService,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
