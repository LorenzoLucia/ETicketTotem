import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_frontend/pay_screen.dart';
import 'package:totem_frontend/services/api_service.dart';

class LicensePlateInputScreen extends StatefulWidget {
  final ApiService apiService;
  const LicensePlateInputScreen({super.key, required this.apiService});

  @override
  State<LicensePlateInputScreen> createState() =>
      _LicensePlateInputScreenState();
}

class _LicensePlateInputScreenState extends State<LicensePlateInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
  void initState() {
    super.initState();
    // Disabilita la tastiera di sistema
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Aggiungi un listener per monitorare i cambiamenti nel testo
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Converti automaticamente in maiuscolo
    final String text = _controller.text;
    final String upperText = text.toUpperCase();

    if (text != upperText) {
      _controller.value = _controller.value.copyWith(
        text: upperText,
        selection: TextSelection.collapsed(offset: upperText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _appendText(String text) {
    if (_controller.text.length < 7) {
      final currentText = _controller.text;
      final newText = currentText + text;

      _controller.text = newText;
      plate = newText;
      setState(() {});
    }
  }

  void _deleteText() {
    if (_controller.text.isNotEmpty) {
      _controller.text = _controller.text.substring(
        0,
        _controller.text.length - 1,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inserire Targa'), centerTitle: true),
      body: GestureDetector(
        onTap: () {
          // Impedisci l'apertura della tastiera di sistema quando clicchi sul campo di testo
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Visualizzazione della targa
                      Container(
                        width: 400,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'AB123CD',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          readOnly: true, // Impedisce la modifica diretta
                          showCursor:
                              true, // Mostra il cursore anche se readOnly
                        ),
                      ),

                      SizedBox(height: 20),

                      Container(
                        width: 400,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zone',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Spacer(),

                            Container(
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'A',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                readOnly: true, // Impedisce la modifica diretta
                                showCursor:
                                    true, // Mostra il cursore anche se readOnly
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        'Select End Time:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Pulsante per confermare l'inserimento
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
                                            duration: selectedTime,
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

            // Tastiera personalizzata fissa
            Container(
              color: Colors.grey.shade200,
              child: Column(
                children: [
                  // Prima riga: lettere
                  // Ultima riga: numeri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 1; i <= 9; i++)
                        _buildKeyboardKey(i.toString()),
                      _buildKeyboardKey('0'),
                    ],
                  ),

                  _buildLetterRow([
                    'Q',
                    'W',
                    'E',
                    'R',
                    'T',
                    'Y',
                    'U',
                    'I',
                    'O',
                    'P',
                  ]),
                  _buildLetterRow([
                    'A',
                    'S',
                    'D',
                    'F',
                    'G',
                    'H',
                    'J',
                    'K',
                    'L',
                  ]),
                  _buildLetterRow(['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'del']),

                  // Padding sul fondo per evitare problemi con i dispositivi con notch
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterRow(List<String> letters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) => _buildKeyboardKey(letter)).toList(),
    );
  }

  Widget _buildKeyboardKey(String text) {
    // Tasto cancella
    if (text == 'del') {
      return InkWell(
        onTap: _deleteText,
        child: Container(
          width: 80,
          height: 50,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.backspace, color: Colors.white),
        ),
      );
    }

    return InkWell(
      onTap: () => _appendText(text),
      child: Container(
        width: 33,
        height: 50,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
