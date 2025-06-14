import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/book_model.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/bookmark.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/library_entry.dart';

class LibraryEntryModel extends LibraryEntry {
  const LibraryEntryModel({
    required super.userId,
    required super.book,
    required super.dateAdded,
    super.lastReadPage,
    super.readingProgress,
    super.bookmarks,
  });

  factory LibraryEntryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, String userId) {
    final data = doc.data()!;
    final bookData = data['bookData'] as Map<String, dynamic>;

    final book = BookModel(
      id: bookData['id'] ?? doc.id,
      title: bookData['title'] ?? 'No Title',
      authors: List<String>.from(bookData['authors'] ?? []),
      description: bookData['description'] ?? '',
      categories: List<String>.from(bookData['categories'] ?? []),
      tags: List<String>.from(bookData['tags'] ?? []),
      publishedYear: bookData['publishedYear'] ?? 0,
      pageCount: bookData['pageCount'] ?? 0,
      coverImageUrl: bookData['coverImageUrl'] ?? '',
      pdfUrl: bookData['pdfUrl'] ?? '',
      averageRating: (bookData['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: bookData['ratingsCount'] ?? 0,
      price: (bookData['price'] as num?)?.toDouble() ?? 0.0, // ✅ added
      genres: List<String>.from(bookData['genres'] ?? []),    // ✅ added
    );

    final bookmarksData = data['bookmarks'] as List<dynamic>? ?? [];
    final bookmarks = bookmarksData.map((bookmarkMap) {
      return Bookmark.fromMap(bookmarkMap as Map<String, dynamic>);
    }).toList();

    return LibraryEntryModel(
      userId: userId,
      book: book,
      dateAdded: (data['dateAdded'] as Timestamp).toDate(),
      lastReadPage: data['lastReadPage'] ?? 1,
      readingProgress: (data['readingProgress'] as num?)?.toDouble() ?? 0.0,
      bookmarks: bookmarks,
    );
  }
}
