// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:totem_frontend/controller_page.dart';
import 'package:totem_frontend/services/api_service.dart';
import 'package:totem_frontend/totem_ticket_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

class HomeScreen extends StatelessWidget {
  final ApiService apiService;
  final Map<String, dynamic> userData;
  final String uid;

  const HomeScreen({
    super.key,
    required this.apiService,
    required this.userData,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    Widget homePage;

    apiService.setUserId(uid);

    switch (userData['role']) {
      case 'CONTROLLER':
        homePage = ParkingControllerPage(apiService: apiService);
        break;
      case 'TOTEM':
        homePage = TotemInputScreen(apiService: apiService);
      default:
        homePage = ErrorPage(apiService: apiService, userData: userData);
        break;
    }

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'eTickets App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: homePage,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class ErrorPage extends StatelessWidget {
  final ApiService apiService;
  final Map<String, dynamic> userData;

  const ErrorPage({
    super.key,
    required this.apiService,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Error Page')),
      body: Center(
        child: Text(
          'Error: Trying to login on a totem with role: ${userData['role']}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
