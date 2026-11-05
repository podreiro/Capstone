import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppBook {
  final String id;
  final String title;
  final List<String> authors;
  final int? year;
  final String? coverUrl;
  final String? description;

  const AppBook({
    required this.id,
    required this.title,
    required this.authors,
    this.year,
    this.coverUrl,
    this.description,
  });

  factory AppBook.fromSearchJson(Map<String, dynamic> json) {
    final key = (json['key'] ?? '').toString();
    final id = key.startsWith('/works/') ? key.substring(7) : key;

    final authors = (json['author_name'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    final coverId = json['cover_i'];
    return AppBook(
      id: id,
      title: (json['title'] ?? 'Sem título').toString(),
      authors: authors,
      year: json['first_publish_year'] is int
          ? json['first_publish_year'] as int
          : int.tryParse('${json['first_publish_year'] ?? ''}'),
      coverUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
          : null,
    );
  }
}

class OpenLibraryService {
  static const _base = 'https://openlibrary.org';

  Future<List<AppBook>> searchBooks(String query) async {
    final uri = Uri.parse(
      '$_base/search.json?q=${Uri.encodeQueryComponent(query)}&limit=24',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar os livros.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = (data['docs'] as List? ?? []);
    return docs
        .whereType<Map>()
        .map((e) => AppBook.fromSearchJson(Map<String, dynamic>.from(e)))
        .where((book) => book.id.isNotEmpty)
        .toList();
  }

  Future<AppBook> getBook(String id) async {
    final response = await http.get(Uri.parse('$_base/works/$id.json'));

    if (response.statusCode != 200) {
      throw Exception('Detalhes do livro não encontrados.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final title = (data['title'] ?? 'Sem título').toString();

    String? description;
    final rawDescription = data['description'];
    if (rawDescription is String) {
      description = rawDescription;
    } else if (rawDescription is Map) {
      description = rawDescription['value']?.toString();
    }

    final covers = (data['covers'] as List?)
        ?.whereType<num>()
        .map((e) => e.toInt())
        .toList();
    final coverUrl = covers != null && covers.isNotEmpty
        ? 'https://covers.openlibrary.org/b/id/${covers.first}-L.jpg'
        : null;

    final authors = <String>[];
    final rawAuthors = data['authors'] as List?;
    if (rawAuthors != null) {
      for (final author in rawAuthors) {
        if (author is Map && author['author'] is Map) {
          final key = author['author']['key']?.toString();
          if (key != null && key.isNotEmpty) {
            authors.add(key.split('/').last.replaceAll('_', ' '));
          }
        }
      }
    }

    return AppBook(
      id: id,
      title: title,
      authors: authors,
      coverUrl: coverUrl,
      description: description,
    );
  }
}

class LocalStore {
  static const favoritesKey = 'favorite_ids';
  static const historyKey = 'history_ids';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Set<String>> getFavorites() async =>
      (await _prefs).getStringList(favoritesKey)?.toSet() ?? <String>{};

  Future<Set<String>> getHistory() async =>
      (await _prefs).getStringList(historyKey)?.toSet() ?? <String>{};

  Future<void> toggleFavorite(String id) async {
    final prefs = await _prefs;
    final values = prefs.getStringList(favoritesKey)?.toSet() ?? <String>{};
    values.contains(id) ? values.remove(id) : values.add(id);
    await prefs.setStringList(favoritesKey, values.toList());
  }

  Future<void> addHistory(String id) async {
    final prefs = await _prefs;
    final values = prefs.getStringList(historyKey)?.toSet() ?? <String>{};
    values.remove(id);
    values.add(id);
    await prefs.setStringList(historyKey, values.toList());
  }
}
