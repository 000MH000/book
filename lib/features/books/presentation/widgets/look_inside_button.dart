import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LookInsideButton extends StatelessWidget {
  final String bookId;
  final String previewUrl;
  final String title;

  const LookInsideButton({
    super.key,
    required this.bookId,
    required this.previewUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.menu_book),
      label: const Text('Read Book'),
      onPressed: previewUrl.isNotEmpty
          ? () {
        context.pushNamed(
          'bookPreview',
          // ** THE FIX: The parameter name must be 'id' to match the route path. **
          pathParameters: {'id': bookId},
          extra: {
            'url': previewUrl,
            'title': title,
            'isFromLibrary': false,
          },
        );
      }
          : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
