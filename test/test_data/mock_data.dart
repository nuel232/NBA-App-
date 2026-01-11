/// Mock data for testing
class MockData {
  static List<Map<String, dynamic>> get mockTeamsData => [
        {
          'id': 1,
          'abbreviation': 'LAL',
          'city': 'Los Angeles',
          'full_name': 'Los Angeles Lakers',
        },
        {
          'id': 2,
          'abbreviation': 'BOS',
          'city': 'Boston',
          'full_name': 'Boston Celtics',
        },
        {
          'id': 3,
          'abbreviation': 'GSW',
          'city': 'Golden State',
          'full_name': 'Golden State Warriors',
        },
      ];

  static List<Map<String, dynamic>> get mockGamesData => [
        {
          'id': 1,
          'date': '2024-01-15',
          'datetime': '2024-01-15T19:00:00Z',
          'season': 2023,
          'status': 'Final',
          'period': 4,
          'time': '',
          'postseason': false,
          'home_team_score': 110,
          'visitor_team_score': 105,
          'home_team': {
            'id': 1,
            'full_name': 'Los Angeles Lakers',
            'abbreviation': 'LAL',
          },
          'visitor_team': {
            'id': 2,
            'full_name': 'Boston Celtics',
            'abbreviation': 'BOS',
          },
        },
        {
          'id': 2,
          'date': '2024-01-16',
          'datetime': '2024-01-16T19:00:00Z',
          'season': 2023,
          'status': 'Final',
          'period': 4,
          'time': '',
          'postseason': false,
          'home_team_score': 98,
          'visitor_team_score': 102,
          'home_team': {
            'id': 3,
            'full_name': 'Golden State Warriors',
            'abbreviation': 'GSW',
          },
          'visitor_team': {
            'id': 1,
            'full_name': 'Los Angeles Lakers',
            'abbreviation': 'LAL',
          },
        },
      ];

  static List<Map<String, dynamic>> get mockPlayerStatsData => [
        {
          'min': '35:00',
          'fgm': 8,
          'fga': 15,
          'fg_pct': 0.533,
          'fg3m': 3,
          'fg3a': 7,
          'fg3_pct': 0.429,
          'ftm': 4,
          'fta': 5,
          'ft_pct': 0.800,
          'oreb': 1,
          'dreb': 5,
          'reb': 6,
          'ast': 8,
          'stl': 2,
          'blk': 1,
          'turnover': 3,
          'pf': 2,
          'pts': 23,
          'player': {
            'id': 1,
            'first_name': 'LeBron',
            'last_name': 'James',
            'position': 'F',
          },
        },
      ];
}
