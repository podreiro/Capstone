import 'package:flutter/material.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/frontend/screens/book_detail_screen.dart';
import 'package:lumen/frontend/widgets/book_cover.dart';

/// Item de lista (telas "Estou lendo" e "Favoritos").
class BookListTile extends StatelessWidget {
  const BookListTile({super.key, required this.book, this.trailing});

  final Book book;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => BookDetailScreen.open(context, book),
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(
          width: 52,
          height: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BookCover(url: book.coverUrl, iconSize: 28),
          ),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          book.authorsLabel,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}
