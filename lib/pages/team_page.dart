import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nba_app/models/team.dart';
import 'package:nba_app/models/live_game.dart';
import 'package:nba_app/models/player_game_stats.dart';
import 'package:nba_app/components/error_widget.dart';
import 'package:nba_app/providers/team_details_provider.dart';

class TeamPage extends StatefulWidget {
  final Team team;
  const TeamPage({super.key, required this.team});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load team data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamDetailsProvider>().loadTeamData(widget.team);
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<TeamDetailsProvider>();
      if (provider.hasMoreGames && !provider.isLoading) {
        provider.loadMoreGames(widget.team);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      margin: const EdgeInsets.all(8),
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: teamWon ? Colors.green[600] : Colors.red[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    teamWon ? "W" : "L",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Score: $score",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
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
  Widget buildTopPlayers(List<PlayerGameStats> playerStats) {
    if (playerStats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "No player stats available",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    // Get all players and calculate average stats
    Map<String, List<PlayerGameStats>> playerStatsMap = {};

    for (var stat in playerStats) {
      String playerKey = "${stat.player.firstName} ${stat.player.lastName}";
      if (playerStatsMap[playerKey] == null) {
        playerStatsMap[playerKey] = [];
      }
      playerStatsMap[playerKey]!.add(stat);
    }

    if (playerStatsMap.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "No player stats available",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    // Calculate averages and get top 5 scorers
    List<MapEntry<String, double>> topScorers = [];
    playerStatsMap.forEach((playerName, statsList) {
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
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Top Players (Avg Points)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...topScorers.map((entry) {
          // Find the player info from the first occurrence
          PlayerGameStats? playerInfo;
          for (var statsList in playerStatsMap.values) {
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

          if (playerInfo == null) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${playerInfo.player.firstName} ${playerInfo.player.lastName}",
                        style: const TextStyle(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.value.toStringAsFixed(1),
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
      body: Consumer<TeamDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.games.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return ErrorDisplayWidget(
              message: provider.errorMessage ?? 'Failed to load team data',
              onRetry: () => provider.loadTeamData(widget.team, refresh: true),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadTeamData(widget.team, refresh: true);
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Info Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(16),
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
                          offset: const Offset(0, 4),
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
                        const SizedBox(height: 12),
                        Text(
                          widget.team.full_name ?? "${widget.team.city} ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Team ID: ${widget.team.id}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recent Games Section
                  if (provider.games.isNotEmpty) ...[
                    const Padding(
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: provider.games.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 250,
                            child: buildGameCard(provider.games[index]),
                          );
                        },
                      ),
                    ),
                  ],

                  // Top Players Section
                  buildTopPlayers(provider.playerStats),

                  // Loading more indicator
                  if (provider.isLoading && provider.games.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // No games message
                  if (provider.games.isEmpty && !provider.isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
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
        },
      ),
    );
  }
}
