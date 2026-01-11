import 'package:flutter/foundation.dart';
import 'package:nba_app/models/team.dart';
import 'package:nba_app/models/live_game.dart';
import 'package:nba_app/models/player_game_stats.dart';
import 'package:nba_app/repositories/team_details_repository.dart';
import 'package:nba_app/core/dependency_injection.dart';
import 'package:nba_app/services/api_service.dart';

enum TeamDetailsState { initial, loading, loaded, error }

class TeamDetailsProvider with ChangeNotifier {
  final ITeamDetailsRepository _teamDetailsRepository;
  
  TeamDetailsProvider({ITeamDetailsRepository? teamDetailsRepository})
      : _teamDetailsRepository = teamDetailsRepository ?? ServiceLocator().teamDetailsRepository;

  TeamDetailsState _state = TeamDetailsState.initial;
  List<LiveGame> _games = [];
  List<PlayerGameStats> _playerStats = [];
  String? _errorMessage;
  bool _hasMoreGames = true;
  int _currentPage = 1;
  final int _gamesPerPage = 10;
  int? _currentTeamId; // Track which team is currently loaded

  TeamDetailsState get state => _state;
  List<LiveGame> get games => _games;
  List<PlayerGameStats> get playerStats => _playerStats;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TeamDetailsState.loading;
  bool get hasError => _state == TeamDetailsState.error;
  bool get hasMoreGames => _hasMoreGames;

  Future<void> loadTeamData(Team team, {bool refresh = false}) async {
    // Reset pagination if switching to a different team or if refresh is true
    final isDifferentTeam = _currentTeamId != null && _currentTeamId != team.id;
    if (refresh || isDifferentTeam) {
      _games = [];
      _playerStats = [];
      _currentPage = 1;
      _hasMoreGames = true;
      _currentTeamId = team.id;
    }

    _state = TeamDetailsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load games and player stats in parallel
      await Future.wait([
        _loadGames(team, refresh: refresh),
        _loadPlayerStats(team),
      ]);

      _state = TeamDetailsState.loaded;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _state = TeamDetailsState.error;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = TeamDetailsState.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load team data. Please try again.';
      _state = TeamDetailsState.error;
      notifyListeners();
    }
  }

  Future<void> _loadGames(Team team, {bool refresh = false}) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = now.subtract(const Duration(days: 30));
      
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final newGames = await _teamDetailsRepository.getTeamGames(
        teamId: team.id,
        startDate: startDateStr,
        endDate: endDateStr,
        page: _currentPage,
        perPage: _gamesPerPage,
      );

      if (newGames.isEmpty) {
        _hasMoreGames = false;
        return;
      }

      newGames.sort((a, b) => b.date.compareTo(a.date));

      if (refresh) {
        _games = newGames.take(10).toList();
      } else {
        _games.addAll(newGames);
      }

      _hasMoreGames = newGames.length == _gamesPerPage;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadPlayerStats(Team team) async {
    try {
      _playerStats = await _teamDetailsRepository.getPlayerStats(
        teamId: team.id,
        perPage: 100,
      );
    } catch (e) {
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
