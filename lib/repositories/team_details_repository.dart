import 'package:nba_app/models/live_game.dart';
import 'package:nba_app/models/player_game_stats.dart';
import 'package:nba_app/services/api_service.dart';
import 'package:nba_app/services/logger_service.dart';

/// Repository for team details data operations
abstract class ITeamDetailsRepository {
  Future<List<LiveGame>> getTeamGames({
    required int teamId,
    required String startDate,
    required String endDate,
    int page,
    int perPage,
  });

  Future<List<PlayerGameStats>> getPlayerStats({
    required int teamId,
    int page,
    int perPage,
  });
}

class TeamDetailsRepository implements ITeamDetailsRepository {
  final ApiService _apiService;
  final LoggerService _logger;

  TeamDetailsRepository({
    required ApiService apiService,
    required LoggerService logger,
  })  : _apiService = apiService,
        _logger = logger;

  @override
  Future<List<LiveGame>> getTeamGames({
    required int teamId,
    required String startDate,
    required String endDate,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      _logger.i('Fetching team games from repository for team $teamId');
      final gamesData = await _apiService.getGames(
        teamId: teamId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        perPage: perPage,
      );

      return gamesData
          .map((gameJson) {
            try {
              return LiveGame.fromJson(gameJson);
            } catch (e) {
              _logger.w('Error parsing game: $e');
              return null;
            }
          })
          .whereType<LiveGame>()
          .toList();
    } catch (e) {
      _logger.e('Error in TeamDetailsRepository.getTeamGames: $e');
      rethrow;
    }
  }

  @override
  Future<List<PlayerGameStats>> getPlayerStats({
    required int teamId,
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      _logger.i('Fetching player stats from repository for team $teamId');
      final statsData = await _apiService.getPlayerStats(
        teamId: teamId,
        page: page,
        perPage: perPage,
      );

      return statsData
          .map((statJson) {
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

              return PlayerGameStats.fromJson(convertedStat);
            } catch (e) {
              _logger.w('Error parsing player stat: $e');
              return null;
            }
          })
          .whereType<PlayerGameStats>()
          .toList();
    } catch (e) {
      _logger.e('Error in TeamDetailsRepository.getPlayerStats: $e');
      rethrow;
    }
  }
}
