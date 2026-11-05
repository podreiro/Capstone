class AppBook {
  final String id;
  final String title;
  final List<String> authors;
  final int? year;
  final String? coverUrl;
  final String? description;
  final List<String> subjects;

  const AppBook({
    required this.id,
    required this.title,
    required this.authors,
    this.year,
    this.coverUrl,
    this.description,
    this.subjects = const [],
  });

  AppBook copyWith({
    String? coverUrl,
    String? description,
    List<String>? subjects,
  }) {
    return AppBook(
      id: id,
      title: title,
      authors: authors,
      year: year,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      subjects: subjects ?? this.subjects,
    );
  }

  static AppBook? fromSearchDoc(Map<String, dynamic> doc) {
    final key = doc['key'];
    final title = doc['title'];
    if (key is! String || title is! String) return null;

    final coverId = doc['cover_i'];
    final subjects = doc['subject'];
    final authors = doc['author_name'];
    final year = doc['first_publish_year'];

    return AppBook(
      id: key.split('/').last,
      title: title,
      authors: authors is List ? authors.map((e) => '$e').toList() : const [],
      year: year is int ? year : null,
      coverUrl: coverId is int ? coverUrlFromId(coverId) : null,
      subjects: subjects is List
          ? subjects.take(8).map((e) => '$e').toList()
          : const [],
    );
  }

  static String coverUrlFromId(int coverId) =>
      'https://covers.openlibrary.org/b/id/$coverId-M.jpg';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'authors': authors,
        'year': year,
        'coverUrl': coverUrl,
        'description': description,
        'subjects': subjects,
      };

  factory AppBook.fromJson(Map<String, dynamic> json) => AppBook(
        id: json['id'] as String,
        title: json['title'] as String,
        authors: (json['authors'] as List? ?? const [])
            .map((e) => '$e')
            .toList(),
        year: json['year'] as int?,
        coverUrl: json['coverUrl'] as String?,
        description: json['description'] as String?,
        subjects: (json['subjects'] as List? ?? const [])
            .map((e) => '$e')
            .toList(),
      );
}
