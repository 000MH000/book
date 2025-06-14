import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import 'package:go_router/go_router.dart';


class SearchResultsScreen extends ConsumerWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Results')),
      body: resultsAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return const Center(child: Text('No results found.'));
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, index) {
              final book = results[index].book;
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.authors.join(', ')),
                trailing: Text('\$${book.price.toStringAsFixed(2)}'),
                onTap: () {
                  context.push('/books/${book.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
