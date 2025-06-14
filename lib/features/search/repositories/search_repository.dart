import 'package:cloud_firestore/cloud_firestore.dart';
import '../../books/domain/entities/book.dart';
import '../../books/domain/entities/scored_book.dart';
import '../utils/scoring_utils.dart';

class SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepository(this._firestore);

  Future<List<ScoredBook>> searchBooks(String query, {double? maxPrice}) async {
    final snapshot = await _firestore.collection('books').get();

    final books = snapshot.docs.map((doc) {
      final data = doc.data();

      return Book(
        id: doc.id,
        title: data['title'] ?? '',
        authors: List<String>.from(data['authors'] ?? []),
        description: data['description'] ?? '',
        categories: List<String>.from(data['categories'] ?? []),
        tags: List<String>.from(data['tags'] ?? []),
        publishedYear: data['publishedYear'] ?? 0,
        pageCount: data['pageCount'] ?? 0,
        coverImageUrl: data['coverImageUrl'] ?? '',
        pdfUrl: data['pdfUrl'] ?? '',
        averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
        ratingsCount: data['ratingsCount'] ?? 0,
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        genres: List<String>.from(data['genres'] ?? []),
      );
    }).toList();

    final results = books
        .map((book) {
      final score = scoreBook(book, query, maxPrice: maxPrice);
      return ScoredBook(book: book, score: score);
    })
        .where((sb) => sb.score >= 2)
        .toList();

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}
