import 'package:flutter/material.dart';
import 'package:platform_commons_task/config/locator.dart';
import 'package:platform_commons_task/service/api_service.dart';
import 'package:platform_commons_task/service/connectivity_service.dart';
import 'package:platform_commons_task/service/database_service.dart';
import 'package:sqflite/sqflite.dart';
import '../models/movie_response.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = locator<ApiService>();
  final DatabaseService _databaseService;
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();

  List<MovieResponse> _movies = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  MovieResponse? _selectedMovie;
  bool _isOfflineMode = false;

  static const int pageSize = 20;

  List<MovieResponse> get movies => _movies;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _currentPage < _totalPages;
  MovieResponse? get selectedMovie => _selectedMovie;
  bool get isOfflineMode => _isOfflineMode;

  MovieProvider(this._databaseService);

  Future<void> loadMovies({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _movies = [];
    }

    if (_isLoading || (!refresh && _currentPage > _totalPages)) return;

    _isLoading = true;
    notifyListeners();

    try {
      bool isConnected = await _connectivityService.isConnected();
      _isOfflineMode = !isConnected;

      if (isConnected) {
        print('Online mode: Loading movies from API - page $_currentPage');
        final response = await _apiService.getTrendingMovies(_currentPage);

        if (refresh) {
          _movies = response.results;
        } else {
          _movies.addAll(response.results);
        }

        _totalPages = response.totalPages;
        _currentPage++;

        print('Saving ${response.results.length} movies to database');
        for (var movie in response.results) {
          try {
            await _databaseService.insertMovie(movie);
            print('Saved movie ID: ${movie.id}');
          } catch (e) {
            print('Error saving movie to database: ${e.toString()}');
          }
        }
      } else {
        print(
            'Offline mode: Loading movies from database - page $_currentPage');

        //final offset = (_currentPage - 1) * pageSize;
        final localMovies = await _databaseService.getMovies(
          page: _currentPage,
          limit: pageSize,
        );

        print('Loaded ${localMovies.length} movies from database');

        if (localMovies.isEmpty) {
          if (_movies.isEmpty) {
            // _errorMessage = 'No movies available offline.';
          }
          print('No more local movies available');
        } else {
          if (refresh) {
            _movies = localMovies;
          } else {
            _movies.addAll(localMovies);
          }
          _currentPage++;
        }

        final db = await _databaseService.database;
        final countResult =
            await db.rawQuery('SELECT COUNT(*) as count FROM movies');
        final totalCount = Sqflite.firstIntValue(countResult) ?? 0;

        _totalPages = (totalCount / pageSize).ceil();
        print(
            'Offline mode - Total local movies: $totalCount, Pages: $_totalPages');
      }
    } catch (e) {
      print('Error loading movies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMovieDetails(int movieId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedMovie = await _apiService.getMovieDetails(movieId);
    } catch (e) {
      print('Error loading movie details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
