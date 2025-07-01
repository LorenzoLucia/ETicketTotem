// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:totem_frontend/consts.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
// import 'firebase_options.dart';

// const clientId = 'YOUR_CLIENT_ID';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // await dotenv.load(fileName: "assets/.env"); // Debug print statement
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _setupStripe();
    runApp(MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Initialization failed: $e'))),
      ),
    );
  }
}

Future<void> _setupStripe() async {
  Stripe.publishableKey = stripePublicKey;
}
