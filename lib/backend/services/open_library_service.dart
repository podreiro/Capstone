import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:lumen/backend/models/book.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Camada HTTP: só fala com a Open Library (https://openlibrary.org/dev/docs/api/search).
/// Não conhece telas nem SharedPreferences.
class OpenLibraryService {
  static const _host = 'openlibrary.org';
  static const _timeout = Duration(seconds: 15);
  static const _searchFields =
      'key,title,author_name,first_publish_year,cover_i,subject';

  final http.Client _client;

  OpenLibraryService({http.Client? client}) : _client = client ?? http.Client();

  /// Lista inicial do catálogo (livros de ficção mais bem avaliados).
  Future<List<AppBook>> listBooks() =>
      _search({'q': 'subject:fiction', 'sort': 'rating'});

  /// GET https://openlibrary.org/search.json?q=...
  Future<List<AppBook>> searchBooks(String query) =>
      _search({'q': query.trim()});

  Future<List<AppBook>> _search(Map<String, String> params) async {
    final uri = Uri.https(_host, '/search.json', {
      ...params,
      'fields': _searchFields,
      'limit': '100',
    });
    final json = await _getJson(uri);
    final docs = json['docs'];
    if (docs is! List) return [];

    final books = <AppBook>[];
    final seen = <String>{};
    for (final doc in docs) {
      if (doc is! Map<String, dynamic>) continue;
      final book = AppBook.fromSearchDoc(doc);
      if (book != null && seen.add(book.id)) books.add(book);
    }
    return books;
  }

  /// GET https://openlibrary.org/works/{id}.json — traz descrição e assuntos.
  /// Os dados já conhecidos da busca ([base]) são preservados.
  Future<AppBook> getBook(AppBook base) async {
    final json = await _getJson(Uri.https(_host, '/works/${base.id}.json'));

    String? description;
    final rawDescription = json['description'];
    if (rawDescription is String) {
      description = rawDescription;
    } else if (rawDescription is Map && rawDescription['value'] is String) {
      description = rawDescription['value'] as String;
    }

    String? coverUrl;
    final covers = json['covers'];
    if (covers is List && covers.isNotEmpty && covers.first is int) {
      final id = covers.first as int;
      if (id > 0) coverUrl = AppBook.coverUrlFromId(id);
    }

    final subjects = json['subjects'];

    return base.copyWith(
      description: description?.trim(),
      coverUrl: base.coverUrl ?? coverUrl,
      subjects: subjects is List && subjects.isNotEmpty
          ? subjects.take(8).map((e) => '$e').toList()
          : null,
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw ApiException('Servidor respondeu ${response.statusCode}.');
      }
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! Map<String, dynamic>) {
        throw const ApiException('Resposta inesperada do servidor.');
      }
      return body;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Tempo esgotado. Verifique sua conexão.');
    } on FormatException {
      throw const ApiException('Resposta inválida do servidor.');
    } catch (_) {
      throw const ApiException('Sem conexão com a internet.');
    }
  }
}
