import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/look_inside_button.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/review_list.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/submit_review_form.dart';
import 'package:mobile_app_project_bookstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:mobile_app_project_bookstore/features/search/screens/search_overlay.dart';

class BookDetailScreen extends ConsumerWidget {
  final String bookId;
  final Map<String, dynamic>? extras;

  const BookDetailScreen({super.key, required this.bookId, this.extras});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsyncValue = ref.watch(bookDetailProvider(bookId));
    final book = bookAsyncValue.value;

    final returnToSearch = extras?['returnToSearch'] == true;

    return WillPopScope(
      onWillPop: () async {
        if (returnToSearch) {
          // Schedule after navigation has popped
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 150), () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const SearchOverlay(),
              );
            });
          });
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(book?.title ?? 'Book Detail'),
        ),
        body: bookAsyncValue.when(
          data: (bookData) {
            if (bookData == null) {
              return const Center(child: Text('Book not found.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bookData.coverImageUrl.isNotEmpty)
                        Hero(
                          tag: 'bookCover-${bookData.id}',
                          child: Image.network(
                            bookData.coverImageUrl,
                            height: 180,
                            width: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(height: 180, width: 120, color: Colors.grey[300], child: const Icon(Icons.book, size: 50)),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bookData.title, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text('by ${bookData.authors.join(", ")}', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(bookData.averageRating.toStringAsFixed(1), style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text('(${bookData.categories.join(", ")})', style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Published: ${bookData.publishedYear} • ${bookData.pageCount} pages', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LookInsideButton(bookId: bookData.id, previewUrl: bookData.pdfUrl, title: bookData.title),
                  const SizedBox(height: 24),
                  Text('Description', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(bookData.description, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  if (bookData.tags.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: bookData.tags.map((tag) => Chip(label: Text(tag))).toList(),
                    ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Reviews (${bookData.ratingsCount})', style: Theme.of(context).textTheme.titleLarge),
                  ReviewList(bookId: bookData.id),
                  const SizedBox(height: 16),
                  SubmitReviewForm(bookId: bookData.id),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Failed to load book details: $err')),
        ),
        floatingActionButton: book != null
            ? FloatingActionButton.extended(
          onPressed: () {
            ref.read(cartProvider.notifier).addToCart(book);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${book.title} added to cart!'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          label: const Text('Add to Cart'),
          icon: const Icon(Icons.add_shopping_cart),
        )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
