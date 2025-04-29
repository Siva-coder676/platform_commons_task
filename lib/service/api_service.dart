import 'package:dio/dio.dart';
import 'package:platform_commons_task/config/api_constants.dart';
import '../models/user_response.dart';
import '../models/movie_response.dart';
import '../models/api_response.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<ApiResponse<UserResponse>> getUsers(int page) async {
    try {
      final response = await _dio.get(
          '${ApiConstants.reqresBaseUrl}/users?page=$page',
          queryParameters: {'api_key': ApiConstants.userApiKey});

      return ApiResponse.fromJson(
          response.data, (json) => UserResponse.fromJson(json));
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<UserResponse> createUser(UserResponse user) async {
    try {
      final response = await _dio.post('${ApiConstants.reqresBaseUrl}/users',
          data: user.toApiJson(),
          queryParameters: {'api_key': ApiConstants.userApiKey});
      print(response.data);
      return UserResponse(
        firstName: user.firstName,
        job: user.job,
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<ApiResponse<MovieResponse>> getTrendingMovies(int page) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.tmdbBaseUrl}/trending/movie/day',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'language': 'en-US',
          'page': page,
        },
      );
      return ApiResponse.fromJson(
          response.data, (json) => MovieResponse.fromJson(json));
    } catch (e) {
      throw Exception('Failed to fetch movies: $e');
    }
  }

  Future<MovieResponse> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.tmdbBaseUrl}/movie/$movieId',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
        },
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch movie details: $e');
    }
  }
}
