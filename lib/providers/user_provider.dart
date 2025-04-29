import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:platform_commons_task/config/locator.dart';
import 'package:platform_commons_task/service/api_service.dart';
import 'package:platform_commons_task/service/connectivity_service.dart';
import 'package:platform_commons_task/service/database_service.dart';
import '../models/user_response.dart';
import '../models/api_response.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final ApiService _apiService = locator<ApiService>();
  final ConnectivityService _connectivityService = locator<ConnectivityService>();

  List<UserResponse> _users = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  UserProvider(this._databaseService);

  List<UserResponse> get users => _users;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _currentPage <= _totalPages;

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _users = [];
    }

    if (_isLoading || (!refresh && _currentPage > _totalPages)) return;

    _isLoading = true;
    notifyListeners();

    try {
      bool isConnected = await _connectivityService.isConnected();
      _isOfflineMode = !isConnected;

      if (isConnected) {
        print('Online mode: Loading from API');
        final response = await _apiService.getUsers(_currentPage);

        if (refresh) {
          _users = response.results;
        } else {
          _users.addAll(response.results);
        }
        _totalPages = response.totalPages;
        _currentPage++;

        print('Saving ${response.results.length} users to database');
        for (var user in response.results) {
          try {
            await _databaseService.insertUser(user);
            print('Saved user ID: ${user.id}');
          } catch (e) {
            print('Error saving user to database: $e');
          }
        }
      } else {
        print('Offline mode: Loading from database');
        final localUsers =
            await _databaseService.getUsers(page: _currentPage, limit: 10);

        print('Loaded ${localUsers.length} users from database');

        if (localUsers.isEmpty) {
          print('No more local users available');
          _totalPages = _currentPage - 1;
        } else {
          if (refresh) {
            _users = localUsers;
          } else {
            _users.addAll(localUsers);
          }
          _currentPage++;
        }
      }
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addUser(UserResponse user) async {
    final isConnected = await _connectivityService.isConnected();

    try {
      if (isConnected) {
        final createdUser = await _apiService.createUser(user);
        _users.add(createdUser);
        notifyListeners();
      } else {
        await _databaseService.insertUser(user);
      }
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }
}
