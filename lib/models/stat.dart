import 'package:nba_app/models/games.dart';
import 'package:nba_app/models/player.dart';
import 'package:nba_app/models/team.dart';

class Stat {
  final int id;
  final double pie;
  final double pace;
  final double assistPercentage;
  final double assistRatio;
  final double assistToTurnover;
  final double defensiveRating;
  final double defensiveReboundPercentage;
  final double effectiveFieldGoalPercentage;
  final double netRating;
  final double offensiveRating;
  final double offensiveReboundPercentage;
  final double reboundPercentage;
  final double trueShootingPercentage;
  final double turnoverRatio;
  final double usagePercentage;
  final Player player;
  final Team team;
  final Game game;

  Stat({
    required this.id,
    required this.pie,
    required this.pace,
    required this.assistPercentage,
    required this.assistRatio,
    required this.assistToTurnover,
    required this.defensiveRating,
    required this.defensiveReboundPercentage,
    required this.effectiveFieldGoalPercentage,
    required this.netRating,
    required this.offensiveRating,
    required this.offensiveReboundPercentage,
    required this.reboundPercentage,
    required this.trueShootingPercentage,
    required this.turnoverRatio,
    required this.usagePercentage,
    required this.player,
    required this.team,
    required this.game,
  });
}
