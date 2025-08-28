import 'package:flutter/material.dart';

class Game {
  final int id;
  final String? date;
  final String? datetime;
  final int season;
  final String status;
  final int period;
  final String? time;
  final bool postseason;
  final int homeTeamScore;
  final int visitorTeamScore;
  final String homeTeam;
  final String visitorTeam;

  Game({
    required this.id,
    required this.date,
    required this.datetime,
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
}
