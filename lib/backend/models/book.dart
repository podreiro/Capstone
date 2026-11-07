/// Tipo de acesso à leitura online informado pela API (campo `ebook_access`).
enum ReadAccess { free, borrow, none }

class Book {
  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.year,
    this.coverId,
    this.description,
    this.subjects = const [],
    this.archiveId,
    this.access = ReadAccess.none,
  });

  /// Identificador da obra na Open Library (ex.: OL45883W).
  final String id;
  final String title;
  final List<String> authors;
  final int? year;
  final int? coverId;
  final String? description;
  final List<String> subjects;

  /// Identificador da edição digital no Internet Archive (campo `ia`).
  final String? archiveId;
  final ReadAccess access;

  String? get coverUrl => coverId == null
      ? null
      : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';

  String? get largeCoverUrl => coverId == null
      ? null
      : 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';

  String get workUrl => 'https://openlibrary.org/works/$id';

  bool get canReadOnline => archiveId != null && access != ReadAccess.none;

  /// Link para ler o livro: edição digital quando existe, senão a página da obra.
  String get readUrl =>
      canReadOnline ? 'https://archive.org/details/$archiveId' : workUrl;

  String get authorsLabel =>
      authors.isEmpty ? 'Autor desconhecido' : authors.join(', ');

  Book copyWith({String? description, List<String>? subjects}) {
    return Book(
      id: id,
      title: title,
      authors: authors,
      year: year,
      coverId: coverId,
      description: description ?? this.description,
      subjects: subjects ?? this.subjects,
      archiveId: archiveId,
      access: access,
    );
  }

  /// Converte um item de `search.json` em [Book].
  factory Book.fromSearchDoc(Map<String, dynamic> json) {
    final key = (json['key'] as String?) ?? '';
    final ia = json['ia'];
    final accessRaw = json['ebook_access'];
    final authors = json['author_name'];
    final subjects = json['subject'];
    final year = json['first_publish_year'];
    final cover = json['cover_i'];

    return Book(
      id: key.split('/').last,
      title: (json['title'] as String?) ?? 'Sem título',
      authors: authors is List ? authors.map((e) => e.toString()).toList() : [],
      year: year is num ? year.toInt() : null,
      coverId: cover is num ? cover.toInt() : null,
      subjects: subjects is List
          ? subjects.map((e) => e.toString()).take(8).toList()
          : [],
      archiveId: ia is List && ia.isNotEmpty ? ia.first.toString() : null,
      access: accessRaw == 'public'
          ? ReadAccess.free
          : accessRaw == 'borrowable'
              ? ReadAccess.borrow
              : ReadAccess.none,
    );
  }

  /// A descrição da obra pode vir como texto ou como `{type, value}`.
  static String? parseDescription(dynamic raw) {
    String? text;
    if (raw is String) {
      text = raw;
    } else if (raw is Map && raw['value'] is String) {
      text = raw['value'] as String;
    }
    if (text == null) return null;
    text = text.split(RegExp(r'\r?\n-{5,}')).first;
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]*\)'),
      (m) => m.group(1) ?? '',
    );
    text = text.replaceAll('\r\n', '\n').trim();
    return text.isEmpty ? null : text;
  }
}
