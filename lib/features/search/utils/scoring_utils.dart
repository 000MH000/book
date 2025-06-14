import '../../books/domain/entities/book.dart';

int scoreBook(Book book, String query, {double? maxPrice}) {
  final tokens = query.toLowerCase().split(RegExp(r'\s+'));
  int score = 0;

  if (book.title.toLowerCase().contains(query.toLowerCase())) {
    score += 10;
  }

  for (final token in tokens) {
    if (book.title.toLowerCase().contains(token)) score += 2;
    if (book.authors.any((author) => author.toLowerCase().contains(token))) score += 5;
    if (book.genres.any((genre) => genre.toLowerCase().contains(token))) score += 2;
    if (book.tags.any((tag) => tag.toLowerCase().contains(token))) score += 2;
    if (book.categories.any((cat) => cat.toLowerCase().contains(token))) score += 2;
  }

  if (maxPrice != null && book.price <= maxPrice) {
    score += 1;
  }

  return score;
}
