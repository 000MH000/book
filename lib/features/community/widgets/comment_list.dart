import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_project_bookstore/features/community/providers/comment_providers.dart';

class CommentList extends ConsumerWidget {
  final String postId;
  const CommentList({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsStreamProvider(postId));

    return commentsAsync.when(
      data: (comments) {
        if (comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: Text('No comments yet.')),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];

            // Safely grab the first letter (or fallback to '?')
            final avatarLetter = comment.authorName.isNotEmpty
                ? comment.authorName[0].toUpperCase()
                : '?';

            return ListTile(
              leading: CircleAvatar(child: Text(avatarLetter)),
              title: Text(
                comment.authorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(comment.text),
              trailing: Text(
                DateFormat.yMd().format(comment.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error loading comments: $err')),
    );
  }
}
