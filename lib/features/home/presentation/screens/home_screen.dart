import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';
import 'package:mobile_app_project_bookstore/features/search/screens/search_overlay.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KetaBook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const SearchOverlay(), // Create this next
              );
            },
          ),
          IconButton(icon: const Icon(Icons.person), onPressed: () {
            // Placeholder for profile navigation or action
          }),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              context.pushNamed('cart');
            },
          ),
        ],
      ),
      body: booksAsyncValue.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(child: Text('No books available right now.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                color: Theme.of(context).cardColor,
                elevation: 2.0,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    context.pushNamed('bookDetails', pathParameters: {'id': book.id});
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Hero(
                          tag: 'bookCover-${book.id}',
                          child: book.coverImageUrl.isNotEmpty
                              ? Image.network(book.coverImageUrl, fit: BoxFit.cover)
                              : Container(color: Colors.grey[200], child: const Icon(Icons.book, size: 50, color: Colors.grey)),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(book.authors.join(', '), style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load books. Please try again later.')),
      ),
    );
  }
}
