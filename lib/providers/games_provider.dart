import 'package:flutter/foundation.dart';
import 'package:nba_app/models/games.dart';
import 'package:nba_app/repositories/games_repository.dart';
import 'package:nba_app/core/dependency_injection.dart';
import 'package:nba_app/services/api_service.dart';

enum GamesState { initial, loading, loaded, error }

class GamesProvider with ChangeNotifier {
  final IGamesRepository _gamesRepository;
  
  GamesProvider({IGamesRepository? gamesRepository})
      : _gamesRepository = gamesRepository ?? ServiceLocator().gamesRepository;

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
    // Reset pagination if refresh is true OR if games list is empty (first load)
    final isFirstLoad = _games.isEmpty;
    
    // If games are already loaded and we're not refreshing, don't reload
    // This prevents duplicate loads when navigating back to the page
    if (!refresh && !isFirstLoad && _state == GamesState.loaded) {
      return;
    }
    
    if (refresh || isFirstLoad) {
      _games = [];
      _currentPage = 1;
      _hasMoreGames = true;
    }

    _state = GamesState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newGames = await _gamesRepository.getGames(
        page: _currentPage,
        perPage: _gamesPerPage,
      );

      if (newGames.isEmpty) {
        _hasMoreGames = false;
        _state = GamesState.loaded;
        notifyListeners();
        return;
      }

      if (refresh || isFirstLoad) {
        _games = newGames;
      } else {
        _games.addAll(newGames);
      }

      _hasMoreGames = newGames.length == _gamesPerPage;
      _state = GamesState.loaded;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _state = GamesState.error;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = GamesState.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load games. Please try again.';
      _state = GamesState.error;
      notifyListeners();
    }
  }

  Future<void> loadMoreGames() async {
    if (!_hasMoreGames || _state == GamesState.loading) {
      return;
    }

    _currentPage++;
    try {
      final newGames = await _gamesRepository.getGames(
        page: _currentPage,
        perPage: _gamesPerPage,
      );

      if (newGames.isEmpty) {
        _hasMoreGames = false;
        notifyListeners();
        return;
      }

      _games.addAll(newGames);
      _hasMoreGames = newGames.length == _gamesPerPage;
      notifyListeners();
    } catch (e) {
      _currentPage--; // Revert page on error
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
