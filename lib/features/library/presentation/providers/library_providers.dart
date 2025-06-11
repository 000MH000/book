import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';
import 'package:mobile_app_project_bookstore/features/library/data/datasources/library_datasource.dart';
import 'package:mobile_app_project_bookstore/features/library/data/repositories/library_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/bookmark.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/library_entry.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/repositories/library_repository.dart';

// Datasource Provider
final libraryDataSourceProvider = Provider<LibraryDataSource>((ref) {
  return LibraryDataSource(FirebaseFirestore.instance);
});

// Repository Provider
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final dataSource = ref.watch(libraryDataSourceProvider);
  return LibraryRepositoryImpl(dataSource);
});

// Provider to add books to the library (the "checkout" action)
final addBooksToLibraryProvider = FutureProvider.autoDispose.family<void, List<CartItem>>((ref, items) async {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User must be logged in.');
  await libraryRepository.addBooksToLibrary(user.uid, items);
});

// Provider to stream the user's library entries
final userLibraryProvider = StreamProvider<List<LibraryEntry>>((ref) {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return libraryRepository.getUserLibrary(user.uid);
  }
  return Stream.value([]);
});

// Provider to get a single library entry for the reader screen
final libraryEntryProvider = StreamProvider.autoDispose.family<LibraryEntry?, String>((ref, bookId) {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  // We want a stream here so the bookmark list in the reader updates in real-time
  return libraryRepository.getUserLibrary(user.uid).map((entries) {
    try {
      return entries.firstWhere((entry) => entry.book.id == bookId);
    } catch (e) {
      return null; // Return null if not found
    }
  });
});

// Provider to update reading progress
final updateProgressProvider = FutureProvider.autoDispose.family<void, ({String bookId, int pageNumber, int totalPages})>((ref, args) async {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not logged in');

  await libraryRepository.updateReadingProgress(
    userId: user.uid,
    bookId: args.bookId,
    pageNumber: args.pageNumber,
    totalPages: args.totalPages,
  );
  ref.invalidate(userLibraryProvider);
});

// ** NEW **: Provider to add a bookmark
final addBookmarkProvider = FutureProvider.autoDispose.family<void, ({String bookId, Bookmark bookmark})>((ref, args) async {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not logged in');

  await libraryRepository.addBookmark(
    userId: user.uid,
    bookId: args.bookId,
    bookmark: args.bookmark,
  );
  ref.invalidate(libraryEntryProvider(args.bookId));
});

// ** NEW **: Provider to remove a bookmark
final removeBookmarkProvider = FutureProvider.autoDispose.family<void, ({String bookId, Bookmark bookmark})>((ref, args) async {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not logged in');

  await libraryRepository.removeBookmark(
    userId: user.uid,
    bookId: args.bookId,
    bookmark: args.bookmark,
  );
  ref.invalidate(libraryEntryProvider(args.bookId));
});
