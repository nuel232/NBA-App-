import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nba_app/pages/home_page.dart';
import 'package:nba_app/providers/teams_provider.dart';
import 'package:nba_app/models/team.dart';
import '../mocks/mock_repositories.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      final provider = TeamsProvider(teamsRepository: MockTeamsRepository());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TeamsProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error widget when error occurs', (tester) async {
      // Arrange
      final provider = TeamsProvider(teamsRepository: MockTeamsRepository());
      await provider.loadTeams(); // This will trigger error with mock

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TeamsProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
    });

    testWidgets('should display teams list when loaded', (tester) async {
      // Arrange
      final mockRepository = MockTeamsRepository();
      when(mockRepository.getTeams()).thenAnswer((_) async => [
            Team(
              id: 1,
              abbreviation: 'LAL',
              city: 'Los Angeles',
              full_name: 'Los Angeles Lakers',
            ),
          ]);

      final provider = TeamsProvider(teamsRepository: mockRepository);
      await provider.loadTeams();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TeamsProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.text('LAL'), findsOneWidget);
      expect(find.text('Los Angeles'), findsOneWidget);
    });

    testWidgets('should navigate to team page on tap', (tester) async {
      // Arrange
      final mockRepository = MockTeamsRepository();
      when(mockRepository.getTeams()).thenAnswer((_) async => [
            Team(
              id: 1,
              abbreviation: 'LAL',
              city: 'Los Angeles',
              full_name: 'Los Angeles Lakers',
            ),
          ]);

      final provider = TeamsProvider(teamsRepository: mockRepository);
      await provider.loadTeams();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TeamsProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('LAL'));
      await tester.pumpAndSettle();

      // Assert - navigation should occur
      // Note: Full navigation test would require TeamPage setup
      expect(find.byType(HomePage), findsNothing);
    });
  });
}
