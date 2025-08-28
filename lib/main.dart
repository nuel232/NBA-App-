import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nba_app/pages/game_page.dart';
import 'package:nba_app/pages/home_page.dart';
import 'package:nba_app/pages/team_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/games': (context) => GamePage(),
        '/TeamPage': (context) => TeamPage(),
      },
    );
  }
}
