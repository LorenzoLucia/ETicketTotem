import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

const String currency = 'eur';
const String stripePublicKey =
    "pk_test_51RVHlfFJ7B2R70XN64ALOdZEKjlPw2FY6kNAPlOw6SGYPsA5DwsvBYQas64ZpSZk5DaUYDCmu4GlF3tNudgfWQuF00QA6PsnFA";
const String stripePrivateKey = "chiave da prendere dalla dashboard stripe";

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  String _calculateCentsAmount(double amount) {
    print(amount);
    final String centsAmount = (amount * 100).toInt().toString();
    print(centsAmount);
    return centsAmount;
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $stripePrivateKey',
      };
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
      final body = {
        'amount': _calculateCentsAmount(amount),
        'currency': currency,
      };

      final response = await http.post(url, headers: headers, body: body);
      print(response.body);

      if (response.statusCode == 200) {
        print("Intent created successfully");
        final data = jsonDecode(response.body);
        print(data["client_secret"]);
        return data["client_secret"];
      } else {
        print(response.reasonPhrase);
        print("Intent not created");
        throw Exception('Stripe Intent error');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> makePayment(double amount) async {
    try {
      String? result = await _createPaymentIntent(amount, currency);
      print(result);
    } catch (e) {
      print(e);
    }
  }
}
