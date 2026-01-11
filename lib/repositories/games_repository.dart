import 'package:nba_app/models/games.dart';
import 'package:nba_app/services/api_service.dart';
import 'package:nba_app/services/logger_service.dart';

/// Repository for games data operations
abstract class IGamesRepository {
  Future<List<Game>> getGames({
    int? teamId,
    String? startDate,
    String? endDate,
    int page,
    int perPage,
  });
}

class GamesRepository implements IGamesRepository {
  final ApiService _apiService;
  final LoggerService _logger;

  GamesRepository({
    required ApiService apiService,
    required LoggerService logger,
  })  : _apiService = apiService,
        _logger = logger;

  @override
  Future<List<Game>> getGames({
    int? teamId,
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 25,
  }) async {
    try {
      _logger.i('Fetching games from repository');
      final gamesData = await _apiService.getGames(
        teamId: teamId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        perPage: perPage,
      );

      return gamesData.map((gameJson) {
        try {
          return Game(
            id: gameJson['id'] as int? ?? 0,
            date: gameJson['date'] as String?,
            datetime: gameJson['datetime'] as String? ?? '',
            season: gameJson['season'] as int? ?? 0,
            status: gameJson['status'] as String? ?? '',
            period: gameJson['period'] as int? ?? 0,
            time: gameJson['time'] as String?,
            postseason: gameJson['postseason'] as bool? ?? false,
            homeTeamScore: gameJson['home_team_score'] as int? ?? 0,
            visitorTeamScore: gameJson['visitor_team_score'] as int? ?? 0,
            homeTeam: (gameJson['home_team'] as Map<String, dynamic>?)?['full_name'] as String? ?? '',
            visitorTeam: (gameJson['visitor_team'] as Map<String, dynamic>?)?['full_name'] as String? ?? '',
          );
        } catch (e) {
          _logger.w('Error parsing game: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      _logger.e('Error in GamesRepository.getGames: $e');
      rethrow;
    }
  }
}
