import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User.guest();
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];
  bool _isLoading = true;

  User get user => _user;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    await prefs.setInt('visit_count', _visitCount);

    _favorites = prefs.getStringList('favorites') ?? [];

    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final String name = prefs.getString('user_name') ?? 'Tamu';
    final String email = prefs.getString('user_email') ?? '';

    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
    _isLoading = false;

    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  Future<void> addFavorite(String favorite) async {
    if (favorite.trim().isEmpty) return;
    _favorites.add(favorite.trim());
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }

  Future<void> removeFavorite(int index) async {
    if (index >= 0 && index < _favorites.length) {
      _favorites.removeAt(index);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favorites);
    }
  }

  Future<String?> saveProfile(String name, String email) async {
    final scriptRegExp = RegExp(r'<[^>]*>|script', caseSensitive: false);
    if (scriptRegExp.hasMatch(name) || scriptRegExp.hasMatch(email)) {
      return 'Karakter atau tag berisiko terdeteksi (<script>)!';
    }

    final prefs = await SharedPreferences.getInstance();
    final String? existingEmail = prefs.getString('user_email');

    if (existingEmail != null && existingEmail == email && _user.email != email) {
      return 'Email ini sudah terdaftar!';
    }

    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setBool('is_logged_in', true);

    _user = User(name: name, email: email, isLoggedIn: true);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);

    _user = User.guest();
    notifyListeners();
  }
}