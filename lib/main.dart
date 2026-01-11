import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:nba_app/pages/game_page.dart';
import 'package:nba_app/pages/home_page.dart';
import 'package:nba_app/providers/teams_provider.dart';
import 'package:nba_app/providers/team_details_provider.dart';
import 'package:nba_app/providers/games_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Handle case where .env file is missing
    debugPrint('Warning: Could not load .env file: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeamsProvider()),
        ChangeNotifierProvider(create: (_) => TeamDetailsProvider()),
        ChangeNotifierProvider(create: (_) => GamesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NBA App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomePage(),
          '/games': (context) => const GamePage(),
        },
      ),
    );
  }
}
