import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.url, this.iconSize = 48});

  final String? url;
  final double iconSize;

  Widget _placeholder(BuildContext context, {Widget? child}) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: child ?? Icon(Icons.menu_book_rounded, size: iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = url;
    if (address == null) return _placeholder(context);

    return Image.network(
      address,
      fit: BoxFit.cover,
      errorBuilder: (ctx, _, __) => _placeholder(ctx),
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return _placeholder(
          ctx,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}
