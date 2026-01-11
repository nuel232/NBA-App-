import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nba_app/repositories/teams_repository.dart';
import 'package:nba_app/services/api_service.dart';
import 'package:nba_app/services/logger_service.dart';
import '../mocks/mock_api_service.dart';
import '../test_data/mock_data.dart';

void main() {
  group('TeamsRepository', () {
    late TeamsRepository repository;
    late MockApiService mockApiService;
    late LoggerService loggerService;

    setUp(() {
      mockApiService = MockApiService();
      loggerService = LoggerService();
      repository = TeamsRepository(
        apiService: mockApiService,
        logger: loggerService,
      );
    });

    test('getTeams should return list of teams', () async {
      // Arrange
      when(mockApiService.getTeams())
          .thenAnswer((_) async => MockData.mockTeamsData);

      // Act
      final teams = await repository.getTeams();

      // Assert
      expect(teams, isNotEmpty);
      expect(teams.length, 3);
      expect(teams.first.id, 1);
      expect(teams.first.abbreviation, 'LAL');
      verify(mockApiService.getTeams()).called(1);
    });

    test('getTeams should handle empty response', () async {
      // Arrange
      when(mockApiService.getTeams()).thenAnswer((_) async => []);

      // Act
      final teams = await repository.getTeams();

      // Assert
      expect(teams, isEmpty);
      verify(mockApiService.getTeams()).called(1);
    });

    test('getTeams should propagate ApiException', () async {
      // Arrange
      when(mockApiService.getTeams())
          .thenThrow(ApiException('API error'));

      // Act & Assert
      expect(
        () => repository.getTeams(),
        throwsA(isA<ApiException>()),
      );
    });

    test('getTeams should propagate NetworkException', () async {
      // Arrange
      when(mockApiService.getTeams())
          .thenThrow(NetworkException('Network error'));

      // Act & Assert
      expect(
        () => repository.getTeams(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
