import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  String get _apiKey => dotenv.env['API_KEY'] ?? '';
  String get _baseUrl => 'api.balldontlie.io';

  Future<http.Response> _makeRequestWithRetry(
    Future<http.Response> Function() request, {
    int retries = maxRetries,
  }) async {
    // Check connectivity first
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw NetworkException('No internet connection. Please check your network settings.');
    }

    int attempt = 0;
    while (attempt < retries) {
      try {
        final response = await request();
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else if (response.statusCode == 401) {
          throw ApiException('Unauthorized. Please check your API key.');
        } else if (response.statusCode == 403) {
          throw ApiException('Access forbidden. Please check your API permissions.');
        } else if (response.statusCode >= 500) {
          // Retry on server errors
          attempt++;
          if (attempt < retries) {
            _logger.w('Server error ${response.statusCode}, retrying... (attempt $attempt/$retries)');
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw ApiException('Server error. Please try again later.');
        } else {
          throw ApiException('Request failed with status ${response.statusCode}');
        }
      } on NetworkException {
        rethrow;
      } on ApiException {
        rethrow;
      } catch (e) {
        attempt++;
        if (attempt < retries) {
          _logger.w('Request failed, retrying... (attempt $attempt/$retries): $e');
          await Future.delayed(retryDelay * attempt);
          continue;
        }
        _logger.e('Request failed after $retries attempts: $e');
        throw ApiException('Failed to fetch data. Please try again later.');
      }
    }
    
    throw ApiException('Request failed after $retries attempts');
  }

  Future<List<Map<String, dynamic>>> getTeams() async {
    try {
      final response = await _makeRequestWithRetry(() async {
        return await http.get(
          Uri.https(_baseUrl, '/v1/teams'),
          headers: {'Authorization': _apiKey},
        );
      });

      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] != null) {
        return List<Map<String, dynamic>>.from(jsonData['data']);
      }
      return [];
    } catch (e) {
      _logger.e('Error fetching teams: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGames({
    int? teamId,
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 25,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (teamId != null) {
        queryParams['team_ids[]'] = teamId.toString();
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final response = await _makeRequestWithRetry(() async {
        return await http.get(
          Uri.https(_baseUrl, '/v1/games', queryParams),
          headers: {'Authorization': _apiKey},
        );
      });

      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] != null) {
        return List<Map<String, dynamic>>.from(jsonData['data']);
      }
      return [];
    } catch (e) {
      _logger.e('Error fetching games: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPlayerStats({
    int? teamId,
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (teamId != null) {
        queryParams['team_ids[]'] = teamId.toString();
      }

      final response = await _makeRequestWithRetry(() async {
        return await http.get(
          Uri.https(_baseUrl, '/v1/stats', queryParams),
          headers: {'Authorization': _apiKey},
        );
      });

      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] != null) {
        return List<Map<String, dynamic>>.from(jsonData['data']);
      }
      return [];
    } catch (e) {
      _logger.e('Error fetching player stats: $e');
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}
