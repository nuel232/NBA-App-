import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nba_app/models/team.dart';
import 'package:nba_app/models/live_game.dart';
import 'package:nba_app/models/player_game_stats.dart';

class TeamPage extends StatefulWidget {
  final Team team;
  const TeamPage({super.key, required this.team});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<LiveGame> teamGames = [];
  List<PlayerGameStats> playerStats = [];
  bool isLoading = true;

  // Get games and player stats for this specific team
  Future<void> getTeamData() async {
    try {
      // Get recent games
      await getTeamGames();

      // Get player stats for this team
      await getPlayerStats();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading team data: $e');
    }
  }

  // Get recent games for this team
  Future<void> getTeamGames() async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = now.subtract(Duration(days: 30));

      var response = await http.get(
        Uri.https('api.balldontlie.io', '/v1/games', {
          'team_ids[]': widget.team.id.toString(),
          'start_date':
              '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
          'end_date':
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          'per_page': '25',
        }),
        headers: {'Authorization': dotenv.env['API_KEY'] ?? ''},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<LiveGame> games = [];

        if (jsonData['data'] != null && jsonData['data'].isNotEmpty) {
          for (var gameJson in jsonData['data']) {
            try {
              games.add(LiveGame.fromJson(gameJson));
            } catch (e) {
              print('Error parsing game: $e');
            }
          }

          games.sort((a, b) => b.date.compareTo(a.date));
          if (games.length > 10) {
            games = games.take(10).toList();
          }
        }

        setState(() {
          teamGames = games;
        });

        print('Loaded ${games.length} games for ${widget.team.abbreviation}');
      }
    } catch (e) {
      print('Error loading team games: $e');
    }
  }

  // Get player stats for this team from the /v1/stats endpoint
  Future<void> getPlayerStats() async {
    try {
      var response = await http.get(
        Uri.https('api.balldontlie.io', '/v1/stats', {
          'team_ids[]': widget.team.id.toString(),
          'per_page': '100', // Get more stats
        }),
        headers: {'Authorization': dotenv.env['API_KEY'] ?? ''},
      );

      print('Player Stats API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<PlayerGameStats> stats = [];

        if (jsonData['data'] != null && jsonData['data'].isNotEmpty) {
          for (var statJson in jsonData['data']) {
            try {
              // Convert the API response to match our PlayerGameStats model
              var convertedStat = {
                'min': statJson['min'],
                'fgm': statJson['fgm'],
                'fga': statJson['fga'],
                'fg_pct': statJson['fg_pct'],
                'fg3m': statJson['fg3m'],
                'fg3a': statJson['fg3a'],
                'fg3_pct': statJson['fg3_pct'],
                'ftm': statJson['ftm'],
                'fta': statJson['fta'],
                'ft_pct': statJson['ft_pct'],
                'oreb': statJson['oreb'],
                'dreb': statJson['dreb'],
                'reb': statJson['reb'],
                'ast': statJson['ast'],
                'stl': statJson['stl'],
                'blk': statJson['blk'],
                'turnover': statJson['turnover'],
                'pf': statJson['pf'],
                'pts': statJson['pts'],
                'player': statJson['player'],
              };

              stats.add(PlayerGameStats.fromJson(convertedStat));
            } catch (e) {
              print('Error parsing player stat: $e');
            }
          }
        }

        setState(() {
          playerStats = stats;
          isLoading = false;
        });

        print(
          'Loaded ${stats.length} player stats for ${widget.team.abbreviation}',
        );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading player stats: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getTeamData();
  }

  // Widget to show individual game
  Widget buildGameCard(LiveGame game) {
    bool isHomeTeam = game.homeTeam.id == widget.team.id;
    String opponent = isHomeTeam
        ? game.visitorTeam.fullName
        : game.homeTeam.fullName;
    String score = "${game.visitorTeamScore} - ${game.homeTeamScore}";

    // Determine if team won
    bool teamWon = false;
    if (isHomeTeam && game.homeTeamScore > game.visitorTeamScore) {
      teamWon = true;
    } else if (!isHomeTeam && game.visitorTeamScore > game.homeTeamScore) {
      teamWon = true;
    }

    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "vs $opponent",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: teamWon ? Colors.green[600] : Colors.red[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    teamWon ? "W" : "L",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Score: $score",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              "Date: ${game.date}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              "Status: ${game.status}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to show top players from recent games
  Widget buildTopPlayers() {
    if (teamGames.isEmpty) return SizedBox.shrink();

    // Get all players from all games and calculate average stats
    Map<String, List<PlayerGameStats>> playerStats = {};

    for (var game in teamGames) {
      List<PlayerGameStats> teamPlayers = [];

      // Check if this team is home or visitor and get the right players
      if (game.homeTeam.id == widget.team.id) {
        teamPlayers = game.homeTeam.players;
      } else {
        teamPlayers = game.visitorTeam.players;
      }

      print(
        'Found ${teamPlayers.length} players for team ${widget.team.abbreviation}',
      );

      for (var player in teamPlayers) {
        String playerKey =
            "${player.player.firstName} ${player.player.lastName}";
        if (playerStats[playerKey] == null) {
          playerStats[playerKey] = [];
        }
        playerStats[playerKey]!.add(player);
      }
    }

    if (playerStats.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "No player stats available",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    // Calculate averages and get top 5 scorers
    List<MapEntry<String, double>> topScorers = [];
    playerStats.forEach((playerName, statsList) {
      double avgPoints =
          statsList.map((s) => s.points).reduce((a, b) => a + b) /
          statsList.length;
      topScorers.add(MapEntry(playerName, avgPoints));
    });

    topScorers.sort((a, b) => b.value.compareTo(a.value));
    topScorers = topScorers.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Top Players (Avg Points)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...topScorers.map((entry) {
          // Find the player info from the first occurrence
          PlayerGameStats? playerInfo;
          for (var statsList in playerStats.values) {
            var found = statsList.firstWhere(
              (s) => "${s.player.firstName} ${s.player.lastName}" == entry.key,
              orElse: () => statsList.first,
            );
            if ("${found.player.firstName} ${found.player.lastName}" ==
                entry.key) {
              playerInfo = found;
              break;
            }
          }

          if (playerInfo == null) return SizedBox.shrink();

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[600],
                  radius: 20,
                  child: Text(
                    playerInfo.player.firstName[0] +
                        playerInfo.player.lastName[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${playerInfo.player.firstName} ${playerInfo.player.lastName}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${playerInfo.player.position} • ${entry.value.toStringAsFixed(1)} PPG",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${entry.value.toStringAsFixed(1)}",
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("${widget.team.full_name ?? widget.team.city} "),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Info Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple[200]!, Colors.blue[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Text(
                            widget.team.abbreviation,
                            style: TextStyle(
                              color: Colors.orange[600],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.team.full_name ?? "${widget.team.city} ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Team ID: ${widget.team.id}",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Recent Games Section
                  if (teamGames.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Recent Games",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        itemCount: teamGames.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 250,
                            child: buildGameCard(teamGames[index]),
                          );
                        },
                      ),
                    ),
                  ],

                  // Top Players Section
                  buildTopPlayers(),

                  // No games message
                  if (teamGames.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No recent games found for this team",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
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
