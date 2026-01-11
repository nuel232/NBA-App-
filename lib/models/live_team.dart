// lib/models/live_team.dart
import 'package:nba_app/models/player_game_stats.dart';

class LiveTeam {
  final int id;
  final String conference;
  final String division;
  final String city;
  final String name;
  final String fullName;
  final String abbreviation;
  final List<PlayerGameStats> players;

  LiveTeam({
    required this.id,
    required this.conference,
    required this.division,
    required this.city,
    required this.name,
    required this.fullName,
    required this.abbreviation,
    required this.players,
  });

  factory LiveTeam.fromJson(Map<String, dynamic> json) {
    List<PlayerGameStats> playersList = [];

    // Convert each player's stats from JSON
    // Note: Players may not always be present in game JSON responses
    if (json['players'] != null && json['players'] is List) {
      for (var playerJson in json['players']) {
        try {
          playersList.add(PlayerGameStats.fromJson(playerJson));
        } catch (e) {
          // Skip invalid player data
          continue;
        }
      }
    }

    return LiveTeam(
      id: json['id'] ?? 0,
      conference: json['conference'] ?? '',
      division: json['division'] ?? '',
      city: json['city'] ?? '',
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      players: playersList,
    );
  }
}
