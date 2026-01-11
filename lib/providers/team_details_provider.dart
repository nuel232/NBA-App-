import 'package:flutter/foundation.dart';
import 'package:nba_app/models/team.dart';
import 'package:nba_app/models/live_game.dart';
import 'package:nba_app/models/player_game_stats.dart';
import 'package:nba_app/services/api_service.dart';
import 'package:nba_app/services/logger_service.dart';

enum TeamDetailsState { initial, loading, loaded, error }

class TeamDetailsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();

  TeamDetailsState _state = TeamDetailsState.initial;
  List<LiveGame> _games = [];
  List<PlayerGameStats> _playerStats = [];
  String? _errorMessage;
  bool _hasMoreGames = true;
  int _currentPage = 1;
  final int _gamesPerPage = 10;

  TeamDetailsState get state => _state;
  List<LiveGame> get games => _games;
  List<PlayerGameStats> get playerStats => _playerStats;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TeamDetailsState.loading;
  bool get hasError => _state == TeamDetailsState.error;
  bool get hasMoreGames => _hasMoreGames;

  Future<void> loadTeamData(Team team, {bool refresh = false}) async {
    if (refresh) {
      _games = [];
      _playerStats = [];
      _currentPage = 1;
      _hasMoreGames = true;
    }

    _state = TeamDetailsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _logger.i('Loading team data for ${team.abbreviation}...');
      
      // Load games and player stats in parallel
      await Future.wait([
        _loadGames(team, refresh: refresh),
        _loadPlayerStats(team),
      ]);

      _state = TeamDetailsState.loaded;
      _logger.i('Loaded ${_games.length} games and ${_playerStats.length} player stats');
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _state = TeamDetailsState.error;
      _logger.e('Network error loading team data: ${e.message}');
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = TeamDetailsState.error;
      _logger.e('API error loading team data: ${e.message}');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load team data. Please try again.';
      _state = TeamDetailsState.error;
      _logger.e('Unexpected error loading team data: $e');
      notifyListeners();
    }
  }

  Future<void> _loadGames(Team team, {bool refresh = false}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = now.subtract(const Duration(days: 30));
      
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final gamesData = await _apiService.getGames(
        teamId: team.id,
        startDate: startDateStr,
        endDate: endDateStr,
        page: _currentPage,
        perPage: _gamesPerPage,
      );

      if (gamesData.isEmpty) {
        _hasMoreGames = false;
        return;
      }

      final newGames = gamesData
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

      newGames.sort((a, b) => b.date.compareTo(a.date));

      if (refresh) {
        _games = newGames.take(10).toList();
      } else {
        _games.addAll(newGames);
      }

      _hasMoreGames = gamesData.length == _gamesPerPage;
    } catch (e) {
      _logger.e('Error loading games: $e');
      rethrow;
    }
  }

  Future<void> _loadPlayerStats(Team team) async {
    try {
      final statsData = await _apiService.getPlayerStats(
        teamId: team.id,
        perPage: 100,
      );

      _playerStats = statsData
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
      _logger.e('Error loading player stats: $e');
      rethrow;
    }
  }

  Future<void> loadMoreGames(Team team) async {
    if (!_hasMoreGames || _state == TeamDetailsState.loading) {
      return;
    }

    _currentPage++;
    try {
      await _loadGames(team);
      notifyListeners();
    } catch (e) {
      _currentPage--; // Revert page on error
      _logger.e('Error loading more games: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == TeamDetailsState.error) {
      _state = TeamDetailsState.initial;
    }
    notifyListeners();
  }
}
