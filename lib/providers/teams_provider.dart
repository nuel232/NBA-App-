import 'package:flutter/foundation.dart';
import 'package:nba_app/models/team.dart';
import 'package:nba_app/repositories/teams_repository.dart';
import 'package:nba_app/core/dependency_injection.dart';
import 'package:nba_app/services/api_service.dart';

enum TeamsState { initial, loading, loaded, error }

class TeamsProvider with ChangeNotifier {
  final ITeamsRepository _teamsRepository;
  
  TeamsProvider({ITeamsRepository? teamsRepository})
      : _teamsRepository = teamsRepository ?? ServiceLocator().teamsRepository;

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
      _teams = await _teamsRepository.getTeams();
      _state = TeamsState.loaded;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _state = TeamsState.error;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = TeamsState.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load teams. Please try again.';
      _state = TeamsState.error;
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
