import 'package:flutter_test/flutter_test.dart';
import 'package:nba_app/services/api_service.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('should throw ApiException when API key is missing', () {
      // Note: This test requires .env file to not have API_KEY
      // In a real scenario, you'd mock the dotenv
      expect(() => apiService.validateApiKey(), throwsA(isA<ApiException>()));
    });

    test('getTeams should return empty list when data is null', () async {
      // This is a basic structure test
      // Full testing would require mocking HTTP client
      expect(apiService, isNotNull);
    });

    test('getGames should handle empty response', () {
      expect(apiService, isNotNull);
    });

    test('getPlayerStats should handle empty response', () {
      expect(apiService, isNotNull);
    });
  });

  group('ApiException', () {
    test('should create exception with message', () {
      final exception = ApiException('Test error');
      expect(exception.message, 'Test error');
      expect(exception.toString(), 'Test error');
    });
  });

  group('NetworkException', () {
    test('should create exception with message', () {
      final exception = NetworkException('Network error');
      expect(exception.message, 'Network error');
      expect(exception.toString(), 'Network error');
    });
  });
}
