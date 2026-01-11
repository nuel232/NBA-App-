import 'package:nba_app/services/api_service.dart';
import 'package:nba_app/services/logger_service.dart';
import 'package:nba_app/repositories/teams_repository.dart';
import 'package:nba_app/repositories/games_repository.dart';
import 'package:nba_app/repositories/team_details_repository.dart';

/// Simple dependency injection container
/// In production, consider using get_it or similar DI framework
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services (singletons)
  ApiService? _apiService;
  LoggerService? _loggerService;

  // Repositories
  TeamsRepository? _teamsRepository;
  GamesRepository? _gamesRepository;
  TeamDetailsRepository? _teamDetailsRepository;

  // Getters with lazy initialization
  ApiService get apiService {
    _apiService ??= ApiService();
    return _apiService!;
  }

  LoggerService get loggerService {
    _loggerService ??= LoggerService();
    return _loggerService!;
  }

  TeamsRepository get teamsRepository {
    _teamsRepository ??= TeamsRepository(
      apiService: apiService,
      logger: loggerService,
    );
    return _teamsRepository!;
  }

  GamesRepository get gamesRepository {
    _gamesRepository ??= GamesRepository(
      apiService: apiService,
      logger: loggerService,
    );
    return _gamesRepository!;
  }

  TeamDetailsRepository get teamDetailsRepository {
    _teamDetailsRepository ??= TeamDetailsRepository(
      apiService: apiService,
      logger: loggerService,
    );
    return _teamDetailsRepository!;
  }

  /// Reset all dependencies (useful for testing)
  void reset() {
    _apiService = null;
    _loggerService = null;
    _teamsRepository = null;
    _gamesRepository = null;
    _teamDetailsRepository = null;
  }
}
