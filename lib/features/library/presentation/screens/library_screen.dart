import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/library/presentation/providers/library_providers.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsyncValue = ref.watch(userLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      body: libraryAsyncValue.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.collections_bookmark_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Your purchased books will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final book = entry.book;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Image.network(
                    book.coverImageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.book, size: 50),
                  ),
                  title: Text(book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.authors.join(', ')),
                      const SizedBox(height: 12),
                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        percent: entry.readingProgress,
                        lineHeight: 8.0,
                        barRadius: const Radius.circular(4),
                        backgroundColor: Colors.grey[300],
                        progressColor: Colors.blueAccent,
                        trailing: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("${(entry.readingProgress * 100).toStringAsFixed(0)}%"),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    context.pushNamed(
                      'bookPreview',
                      // ** THE FIX: The parameter name must be 'id' to match the route path. **
                      pathParameters: {'id': book.id},
                      extra: {
                        'url': book.pdfUrl,
                        'title': book.title,
                        'initialPage': entry.lastReadPage,
                        'isFromLibrary': true,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading library: $err')),
      ),
    );
  }
}
