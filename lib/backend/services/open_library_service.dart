import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:lumen/backend/models/book.dart';

/// Erro de rede/API já com mensagem pronta para exibir ao usuário.
class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SearchResult {
  const SearchResult({required this.books, required this.total});
  final List<Book> books;
  final int total;
}

/// Cliente HTTP da API pública da Open Library (sem chave de acesso).
/// Docs: https://openlibrary.org/dev/docs/api/search
class OpenLibraryService {
  OpenLibraryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _host = 'openlibrary.org';
  static const _fields =
      'key,title,author_name,first_publish_year,cover_i,ia,ebook_access,subject';

  Uri _searchUri(String q, {int page = 1, int limit = 24, String? sort}) {
    return Uri.https(_host, '/search.json', {
      'q': q,
      'page': '$page',
      'limit': '$limit',
      'fields': _fields,
      if (sort != null) 'sort': sort,
    });
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ApiException(
          'O servidor respondeu com erro (${response.statusCode}). '
          'Tente novamente em instantes.',
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw ApiException('Resposta inesperada do servidor.');
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('A conexão demorou demais. Tente novamente.');
    } on FormatException {
      throw ApiException('Não foi possível interpretar a resposta do servidor.');
    } catch (_) {
      throw ApiException(
        'Sem conexão com a internet ou servidor indisponível.',
      );
    }
  }

  List<Book> _parseDocs(Map<String, dynamic> json) {
    try {
      final docs = (json['docs'] as List?) ?? const [];
      return docs
          .whereType<Map<String, dynamic>>()
          .where((d) => (d['key'] as String?)?.startsWith('/works/') == true)
          .map(Book.fromSearchDoc)
          .toList();
    } catch (_) {
      throw ApiException('Resposta inesperada do servidor.');
    }
  }

  /// GET /search.json?q=...  (lista, catálogo por categoria e busca)
  Future<SearchResult> searchBooks({
    required String query,
    int page = 1,
    int limit = 24,
    String? sort,
  }) async {
    final json = await _getJson(
      _searchUri(query, page: page, limit: limit, sort: sort),
    );
    final books = _parseDocs(json);
    final total = json['numFound'];
    return SearchResult(
      books: books,
      total: total is num ? total.toInt() : books.length,
    );
  }

  /// Recupera os dados básicos de uma obra a partir do ID salvo localmente.
  Future<Book?> getBookById(String id) async {
    final json = await _getJson(_searchUri('key:"/works/$id"', limit: 1));
    final books = _parseDocs(json);
    return books.isEmpty ? null : books.first;
  }

  /// GET /works/{id}.json  (descrição e assuntos completos)
  Future<Book> fetchDetails(Book book) async {
    final json = await _getJson(Uri.https(_host, '/works/${book.id}.json'));
    try {
      final description = Book.parseDescription(json['description']);
      final rawSubjects = json['subjects'];
      final subjects = rawSubjects is List
          ? rawSubjects.map((e) => e.toString()).take(8).toList()
          : <String>[];
      return book.copyWith(
        description: description,
        subjects: subjects.isEmpty ? book.subjects : subjects,
      );
    } catch (_) {
      throw ApiException('Resposta inesperada do servidor.');
    }
  }
}
