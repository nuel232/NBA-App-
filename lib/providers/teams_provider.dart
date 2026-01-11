import 'package:flutter/foundation.dart';
import 'package:nba_app/models/team.dart';
import 'package:nba_app/services/api_service.dart';
import 'package:nba_app/services/logger_service.dart';

enum TeamsState { initial, loading, loaded, error }

class TeamsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();

  TeamsState _state = TeamsState.initial;
  List<Team> _teams = [];
  String? _errorMessage;

  TeamsState get state => _state;
  List<Team> get teams => _teams;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TeamsState.loading;
  bool get hasError => _state == TeamsState.error;

  Future<void> loadTeams({bool refresh = false}) async {
    if (!refresh && _state == TeamsState.loaded) {
      return;
    }

    _state = TeamsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _logger.i('Loading teams...');
      final teamsData = await _apiService.getTeams();
      
      _teams = teamsData.map((teamJson) {
        return Team(
          full_name: teamJson['full_name'] ?? teamJson['abbreviation'],
          id: teamJson['id'],
          abbreviation: teamJson['abbreviation'],
          city: teamJson['city'],
        );
      }).toList();

      _state = TeamsState.loaded;
      _logger.i('Loaded ${_teams.length} teams');
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _state = TeamsState.error;
      _logger.e('Network error loading teams: ${e.message}');
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = TeamsState.error;
      _logger.e('API error loading teams: ${e.message}');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load teams. Please try again.';
      _state = TeamsState.error;
      _logger.e('Unexpected error loading teams: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == TeamsState.error) {
      _state = TeamsState.initial;
    }
    notifyListeners();
  }
}
