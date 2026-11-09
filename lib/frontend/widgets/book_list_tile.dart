import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/frontend/screens/book_detail_screen.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_cover.dart';

/// Item de lista (telas "Estou lendo" e "Favoritos").
class BookListTile extends StatelessWidget {
  const BookListTile({super.key, required this.book, this.trailing});

  final Book book;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => BookDetailScreen.open(context, book),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: SizedBox(
          width: 48,
          height: 68,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: BookCover(url: book.coverUrl, iconSize: 24),
          ),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            book.authorsLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textMuted,
            ),
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: colors.textMuted,
            ),
      ),
    );
  }
}
