import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nba_app/models/games.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Game> games = [];

  //get teams
  Future getGame() async {
    var response = await http.get(
      Uri.https('api.balldontlie.io', '/v1/games'),
      headers: {'Authorization': dotenv.env['API_KEY'] ?? ''},
    );
    var jsonData = jsonDecode(response.body);

    for (var eachGame in jsonData['data']) {
      final game = Game(
        id: eachGame['id'],
        date: eachGame['date'] ?? "",
        datetime: eachGame['datetime'] ?? '',
        season: eachGame['season'],
        status: eachGame['status'],
        period: eachGame['period'],
        time: eachGame['time'] ?? "",
        postseason: eachGame['postseason'],
        homeTeamScore: eachGame['home_team_score'],
        visitorTeamScore: eachGame['visitor_team_score'],
        homeTeam: eachGame['home_team']['full_name'],
        visitorTeam: eachGame['visitor_team']['full_name'],
      );
      games.add(game);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('NBA GAMES'),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
      ),
      body: FutureBuilder(
        future: getGame(),
        builder: (context, snapshot) {
          //is it done loading? then show team data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No games found"));
          } else {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(games[index].homeTeam),
                  subtitle: Text(games[index].visitorTeam),
                  trailing: Text(games[index].status),
                );
              },
            );
          }
        },
      ),
    );
  }
}
