import 'package:nba_app/models/live_team.dart';

class LiveGame {
  final String date;
  final int season;
  final String status;
  final int period;
  final String time;
  final bool postseason;
  final int homeTeamScore;
  final int visitorTeamScore;
  final LiveTeam homeTeam;
  final LiveTeam visitorTeam;

  LiveGame({
    required this.date,
    required this.season,
    required this.status,
    required this.period,
    required this.time,
    required this.postseason,
    required this.homeTeamScore,
    required this.visitorTeamScore,
    required this.homeTeam,
    required this.visitorTeam,
  });

  factory LiveGame.fromJson(Map<String, dynamic> json) {
    return LiveGame(
      date: json['date'] ?? '',
      season: json['season'] ?? 0,
      status: json['status'] ?? '',
      period: json['period'] ?? 0,
      time: json['time'] ?? '',
      postseason: json['postseason'] ?? false,
      homeTeamScore: json['home_team_score'] ?? 0,
      visitorTeamScore: json['visitor_team_score'] ?? 0,
      homeTeam: LiveTeam.fromJson(json['home_team']),
      visitorTeam: LiveTeam.fromJson(json['visitor_team']),
    );
  }
  // Helper method to get the winning team
  String getWinner() {
    if (homeTeamScore > visitorTeamScore) {
      return homeTeam.fullName;
    } else if (visitorTeamScore > homeTeamScore) {
      return visitorTeam.fullName;
    } else {
      return "Tie";
    }
  }

  // Helper method to get game score as a string
  String getScoreString() {
    return "$visitorTeamScore - $homeTeamScore";
  }
}
