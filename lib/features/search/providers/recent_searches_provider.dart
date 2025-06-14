import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'recent_searches';
const int maxRecentSearches = 5;

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>(
      (ref) => RecentSearchesNotifier()..loadFromPrefs(),
);

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key) ?? [];
    state = stored;
  }

  Future<void> addSearch(String query) async {
    query = query.trim();
    if (query.isEmpty) return;

    final updated = [
      query,
      ...state.where((q) => q != query),
    ].take(maxRecentSearches).toList();

    state = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated);
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
