import 'package:flutter/material.dart';

import 'package:lumen/frontend/theme/app_theme.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.url,
    this.iconSize = 48,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double iconSize;
  final BoxFit fit;

  Widget _placeholder(BuildContext context, {Widget? child}) {
    final colors = context.lumen;

    return Container(
      color: colors.card,
      alignment: Alignment.center,
      child: child ??
          Icon(
            Icons.menu_book_rounded,
            size: iconSize,
            color: colors.accent.withAlpha(120),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;
    final address = url;
    if (address == null) return _placeholder(context);

    return Image.network(
      address,
      fit: fit,
      errorBuilder: (ctx, _, __) => _placeholder(ctx),
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return _placeholder(
          ctx,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.accent,
            ),
          ),
        );
      },
    );
  }
}
