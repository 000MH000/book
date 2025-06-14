import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/search_repository.dart';
import '../../books/domain/entities/scored_book.dart';

/// StateProvider to hold the current search query.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Optional: Provider to hold max price filter
final maxPriceProvider = StateProvider<double?>((ref) => null);

/// Provider for the repository (can be mocked in tests)
final searchRepositoryProvider = Provider(
      (ref) => SearchRepository(FirebaseFirestore.instance),
);

/// FutureProvider to perform the search
final searchResultsProvider = FutureProvider.autoDispose<List<ScoredBook>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final maxPrice = ref.watch(maxPriceProvider);
  final repository = ref.watch(searchRepositoryProvider);

  if (query.trim().isEmpty) return [];

  return await repository.searchBooks(query, maxPrice: maxPrice);
});
