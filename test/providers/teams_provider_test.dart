import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nba_app/providers/teams_provider.dart';
import 'package:nba_app/models/team.dart';
import 'package:nba_app/repositories/teams_repository.dart';
import '../mocks/mock_repositories.dart';
import '../test_data/mock_data.dart';

void main() {
  group('TeamsProvider', () {
    late TeamsProvider provider;
    late MockTeamsRepository mockRepository;

    setUp(() {
      mockRepository = MockTeamsRepository();
      provider = TeamsProvider(teamsRepository: mockRepository);
    });

    test('initial state should be initial', () {
      expect(provider.state, TeamsState.initial);
      expect(provider.teams, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.hasError, false);
    });

    test('loadTeams should set loading state', () async {
      // Arrange
      when(mockRepository.getTeams()).thenAnswer((_) async => [
            Team(
              id: 1,
              abbreviation: 'LAL',
              city: 'Los Angeles',
              full_name: 'Los Angeles Lakers',
            ),
          ]);

      // Act
      final future = provider.loadTeams();

      // Assert - check loading state immediately
      expect(provider.isLoading, true);
      expect(provider.state, TeamsState.loading);

      await future;

      // Assert - check loaded state
      expect(provider.isLoading, false);
      expect(provider.state, TeamsState.loaded);
      expect(provider.teams.length, 1);
    });

    test('loadTeams should handle errors', () async {
      // Arrange
      when(mockRepository.getTeams())
          .thenThrow(Exception('Network error'));

      // Act
      await provider.loadTeams();

      // Assert
      expect(provider.hasError, true);
      expect(provider.state, TeamsState.error);
      expect(provider.errorMessage, isNotNull);
      expect(provider.teams, isEmpty);
    });

    test('clearError should reset error state', () async {
      // Arrange
      when(mockRepository.getTeams())
          .thenThrow(Exception('Error'));
      await provider.loadTeams();
      expect(provider.hasError, true);

      // Act
      provider.clearError();

      // Assert
      expect(provider.hasError, false);
      expect(provider.errorMessage, isNull);
      expect(provider.state, TeamsState.initial);
    });

    test('should not reload if already loaded and refresh is false', () async {
      // Arrange
      when(mockRepository.getTeams()).thenAnswer((_) async => [
            Team(
              id: 1,
              abbreviation: 'LAL',
              city: 'Los Angeles',
              full_name: 'Los Angeles Lakers',
            ),
          ]);

      // Act
      await provider.loadTeams();
      await provider.loadTeams(refresh: false);

      // Assert - should only call once
      verify(mockRepository.getTeams()).called(1);
    });

    test('should reload if refresh is true', () async {
      // Arrange
      when(mockRepository.getTeams()).thenAnswer((_) async => [
            Team(
              id: 1,
              abbreviation: 'LAL',
              city: 'Los Angeles',
              full_name: 'Los Angeles Lakers',
            ),
          ]);

      // Act
      await provider.loadTeams();
      await provider.loadTeams(refresh: true);

      // Assert - should call twice
      verify(mockRepository.getTeams()).called(2);
    });
  });
}
