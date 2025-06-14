import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/data/datasources/book_firestore_datasource.dart';
import 'package:mobile_app_project_bookstore/features/books/data/repositories/book_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/repositories/book_repository.dart';

// Provider for the BookRepository implementation
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final dataSource = BookFirestoreDataSource(firestore);
  return BookRepositoryImpl(firestoreDataSource: dataSource);
});

// Provider to fetch all books
final allBooksProvider = FutureProvider<List<Book>>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getAllBooks();
});

// Provider to fetch a single book by its ID
final bookByIdProvider = FutureProvider.autoDispose.family<Book?, String>((ref, bookId) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBookById(bookId);
});