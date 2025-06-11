import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/review.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';

class SubmitReviewForm extends ConsumerStatefulWidget {
  final String bookId;
  const SubmitReviewForm({super.key, required this.bookId});

  @override
  ConsumerState<SubmitReviewForm> createState() => _SubmitReviewFormState();
}

class _SubmitReviewFormState extends ConsumerState<SubmitReviewForm> {
  final _formKey = GlobalKey<FormState>();
  double _currentRating = 3.0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit a review.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final reviewToSubmit = Review(
          id: '', // Firestore will generate this
          userId: currentUser.uid,
          userName: currentUser.displayName ?? currentUser.email ?? 'Anonymous User',
          rating: _currentRating,
          comment: _commentController.text,
          timestamp: DateTime.now(),
        );

        await ref.read(submitReviewProvider)(
          bookId: widget.bookId,
          review: reviewToSubmit,
        );

        ref.invalidate(bookReviewsProvider(widget.bookId));
        ref.invalidate(bookDetailProvider(widget.bookId));

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
          _commentController.clear();
          setState(() => _currentRating = 3.0);
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit review: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateChangesProvider).value;

    if (currentUser == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please sign in to leave a review.')),
            );
          },
          child: const Text('Sign in to leave a review'),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Leave your review', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('Rating: ${_currentRating.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodyLarge),
          Slider(
            value: _currentRating,
            min: 1,
            max: 5,
            divisions: 8,
            label: _currentRating.toStringAsFixed(1),
            onChanged: (double value) => setState(() => _currentRating = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Your Comment',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your comment.';
              }
              if (value.trim().length < 10) {
                return 'Comment must be at least 10 characters long.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Submit Review'),
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}
