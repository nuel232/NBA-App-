import 'package:flutter/foundation.dart';
import 'package:nba_app/models/games.dart';
import 'package:nba_app/services/api_service.dart';
import 'package:nba_app/services/logger_service.dart';

enum GamesState { initial, loading, loaded, error }

class GamesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();

  GamesState _state = GamesState.initial;
  List<Game> _games = [];
  String? _errorMessage;
  bool _hasMoreGames = true;
  int _currentPage = 1;
  final int _gamesPerPage = 25;

  GamesState get state => _state;
  List<Game> get games => _games;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == GamesState.loading;
  bool get hasError => _state == GamesState.error;
  bool get hasMoreGames => _hasMoreGames;

  Future<void> loadGames({bool refresh = false}) async {
    if (refresh) {
      _games = [];
      _currentPage = 1;
      _hasMoreGames = true;
    }

    _state = GamesState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _logger.i('Loading games...');
      final gamesData = await _apiService.getGames(
        page: _currentPage,
        perPage: _gamesPerPage,
      );

      if (gamesData.isEmpty) {
        _hasMoreGames = false;
        _state = GamesState.loaded;
        notifyListeners();
        return;
      }

      final newGames = gamesData.map((gameJson) {
        return Game(
          id: gameJson['id'],
          date: gameJson['date'] ?? "",
          datetime: gameJson['datetime'] ?? '',
          season: gameJson['season'],
          status: gameJson['status'],
          period: gameJson['period'],
          time: gameJson['time'] ?? "",
          postseason: gameJson['postseason'],
          homeTeamScore: gameJson['home_team_score'],
          visitorTeamScore: gameJson['visitor_team_score'],
          homeTeam: gameJson['home_team']['full_name'],
          visitorTeam: gameJson['visitor_team']['full_name'],
        );
      }).toList();

      if (refresh) {
        _games = newGames;
      } else {
        _games.addAll(newGames);
      }

      _hasMoreGames = gamesData.length == _gamesPerPage;
      _state = GamesState.loaded;
      _logger.i('Loaded ${_games.length} games');
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _state = GamesState.error;
      _logger.e('Network error loading games: ${e.message}');
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = GamesState.error;
      _logger.e('API error loading games: ${e.message}');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load games. Please try again.';
      _state = GamesState.error;
      _logger.e('Unexpected error loading games: $e');
      notifyListeners();
    }
  }

  Future<void> loadMoreGames() async {
    if (!_hasMoreGames || _state == GamesState.loading) {
      return;
    }

    _currentPage++;
    try {
      final gamesData = await _apiService.getGames(
        page: _currentPage,
        perPage: _gamesPerPage,
      );

      if (gamesData.isEmpty) {
        _hasMoreGames = false;
        notifyListeners();
        return;
      }

      final newGames = gamesData.map((gameJson) {
        return Game(
          id: gameJson['id'],
          date: gameJson['date'] ?? "",
          datetime: gameJson['datetime'] ?? '',
          season: gameJson['season'],
          status: gameJson['status'],
          period: gameJson['period'],
          time: gameJson['time'] ?? "",
          postseason: gameJson['postseason'],
          homeTeamScore: gameJson['home_team_score'],
          visitorTeamScore: gameJson['visitor_team_score'],
          homeTeam: gameJson['home_team']['full_name'],
          visitorTeam: gameJson['visitor_team']['full_name'],
        );
      }).toList();

      _games.addAll(newGames);
      _hasMoreGames = gamesData.length == _gamesPerPage;
      notifyListeners();
    } catch (e) {
      _currentPage--; // Revert page on error
      _logger.e('Error loading more games: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == GamesState.error) {
      _state = GamesState.initial;
    }
    notifyListeners();
  }
}
