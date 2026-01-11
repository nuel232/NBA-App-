import 'package:nba_app/models/team.dart';
import 'package:nba_app/services/api_service.dart';
import 'package:nba_app/services/logger_service.dart';

/// Repository for teams data operations
/// Abstracts data source (API, cache, etc.) from business logic
abstract class ITeamsRepository {
  Future<List<Team>> getTeams();
}

class TeamsRepository implements ITeamsRepository {
  final ApiService _apiService;
  final LoggerService _logger;

  TeamsRepository({
    required ApiService apiService,
    required LoggerService logger,
  })  : _apiService = apiService,
        _logger = logger;

  @override
  Future<List<Team>> getTeams() async {
    try {
      _logger.i('Fetching teams from repository');
      final teamsData = await _apiService.getTeams();

      return teamsData.map((teamJson) {
        try {
          return Team(
            full_name: teamJson['full_name'] as String? ?? 
                      teamJson['abbreviation'] as String? ?? '',
            id: teamJson['id'] as int? ?? 0,
            abbreviation: teamJson['abbreviation'] as String? ?? '',
            city: teamJson['city'] as String? ?? '',
          );
        } catch (e) {
          _logger.w('Error parsing team: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      _logger.e('Error in TeamsRepository.getTeams: $e');
      rethrow;
    }
  }
}
