// lib/models/live_player.dart
class LivePlayer {
  final int id;
  final String firstName;
  final String lastName;
  final String position;
  final String? height;
  final String? weight;
  final String? jerseyNumber;
  final String? college;
  final String? country;
  final int? draftYear;
  final int? draftRound;
  final int? draftNumber;

  LivePlayer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.position,
    this.height,
    this.weight,
    this.jerseyNumber,
    this.college,
    this.country,
    this.draftYear,
    this.draftRound,
    this.draftNumber,
  });

  // Convert JSON to LivePlayer object
  factory LivePlayer.fromJson(Map<String, dynamic> json) {
    return LivePlayer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      position: json['position'],
      height: json['height'],
      weight: json['weight'],
      jerseyNumber: json['jersey_number'],
      college: json['college'],
      country: json['country'],
      draftYear: json['draft_year'],
      draftRound: json['draft_round'],
      draftNumber: json['draft_number'],
    );
  }
}

// lib/models/player_game_stats.dart
class PlayerGameStats {
  final String minutes;
  final int fieldGoalsMade;
  final int fieldGoalsAttempted;
  final double fieldGoalPercentage;
  final int threePointsMade;
  final int threePointsAttempted;
  final double threePointPercentage;
  final int freeThrowsMade;
  final int freeThrowsAttempted;
  final double freeThrowPercentage;
  final int offensiveRebounds;
  final int defensiveRebounds;
  final int totalRebounds;
  final int assists;
  final int steals;
  final int blocks;
  final int turnovers;
  final int personalFouls;
  final int points;
  final LivePlayer player;

  PlayerGameStats({
    required this.minutes,
    required this.fieldGoalsMade,
    required this.fieldGoalsAttempted,
    required this.fieldGoalPercentage,
    required this.threePointsMade,
    required this.threePointsAttempted,
    required this.threePointPercentage,
    required this.freeThrowsMade,
    required this.freeThrowsAttempted,
    required this.freeThrowPercentage,
    required this.offensiveRebounds,
    required this.defensiveRebounds,
    required this.totalRebounds,
    required this.assists,
    required this.steals,
    required this.blocks,
    required this.turnovers,
    required this.personalFouls,
    required this.points,
    required this.player,
  });

  factory PlayerGameStats.fromJson(Map<String, dynamic> json) {
    return PlayerGameStats(
      minutes: json['min'] ?? "0",
      fieldGoalsMade: json['fgm'] ?? 0,
      fieldGoalsAttempted: json['fga'] ?? 0,
      fieldGoalPercentage: (json['fg_pct'] ?? 0).toDouble(),
      threePointsMade: json['fg3m'] ?? 0,
      threePointsAttempted: json['fg3a'] ?? 0,
      threePointPercentage: (json['fg3_pct'] ?? 0).toDouble(),
      freeThrowsMade: json['ftm'] ?? 0,
      freeThrowsAttempted: json['fta'] ?? 0,
      freeThrowPercentage: (json['ft_pct'] ?? 0).toDouble(),
      offensiveRebounds: json['oreb'] ?? 0,
      defensiveRebounds: json['dreb'] ?? 0,
      totalRebounds: json['reb'] ?? 0,
      assists: json['ast'] ?? 0,
      steals: json['stl'] ?? 0,
      blocks: json['blk'] ?? 0,
      turnovers: json['turnover'] ?? 0,
      personalFouls: json['pf'] ?? 0,
      points: json['pts'] ?? 0,
      player: LivePlayer.fromJson(json['player']),
    );
  }
}
