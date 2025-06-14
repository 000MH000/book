import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../books/domain/entities/book.dart';
import '../providers/search_provider.dart';
import '../../books/domain/entities/scored_book.dart';
import 'search_results_screen.dart';
import 'package:go_router/go_router.dart';
import '../providers/recent_searches_provider.dart';

class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final query = ref.read(searchQueryProvider);
    _controller = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6, // Fixed height (~60% screen)
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Search books...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
              ),
              const SizedBox(height: 12),
              if (recentSearches.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recent Searches',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: recentSearches.map((q) => ActionChip(
                    label: Text(q),
                    onPressed: () {
                      _controller.text = q;
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: q.length),
                      );
                      ref.read(searchQueryProvider.notifier).state = q;
                    },
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              Expanded( // Make search results scrollable inside fixed height
                child: resultsAsync.when(
                  data: (results) {
                    final topResults = results.take(5).toList();
                    if (topResults.isEmpty) {
                      return const Center(child: Text('No matches yet...'));
                    }
                    return ListView(
                      children: [
                        ...topResults.map((sb) => ListTile(
                          title: Text(sb.book.title),
                          subtitle: Text(sb.book.authors.join(', ')),
                          onTap: () {
                            ref.read(recentSearchesProvider.notifier).addSearch(_controller.text);
                            Navigator.pop(context);
                            context.push(
                              '/books/${sb.book.id}',
                              extra: {'returnToSearch': true},
                            );
                          },
                        )),
                        TextButton(
                          onPressed: () {
                            ref.read(recentSearchesProvider.notifier).addSearch(_controller.text);
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
                            );
                          },
                          child: const Text('See all results'),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

