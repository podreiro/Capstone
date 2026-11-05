import 'package:shared_preferences/shared_preferences.dart';

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
}

/// Catálogo local: substitui a antiga integração com a API.
/// Mantém os mesmos métodos assíncronos, então as telas não mudam.
class CatalogoLocal {
  static const List<AppBook> _livros = [
    AppBook(
      id: 'dom-casmurro',
      title: 'Dom Casmurro',
      authors: ['Machado de Assis'],
      year: 1899,
      subjects: ['romance', 'clássico', 'literatura brasileira'],
      description:
          'Bentinho, já maduro, revisita a juventude e o amor por Capitu. '
          'Entre lembranças e ciúmes, o leitor precisa decidir em quem confiar.',
    ),
    AppBook(
      id: 'memorias-postumas',
      title: 'Memórias Póstumas de Brás Cubas',
      authors: ['Machado de Assis'],
      year: 1881,
      subjects: ['romance', 'clássico', 'sátira', 'literatura brasileira'],
      description:
          'Um defunto autor conta a própria vida com ironia e humor ácido, '
          'em uma sátira afiada da sociedade do século XIX.',
    ),
    AppBook(
      id: 'o-cortico',
      title: 'O Cortiço',
      authors: ['Aluísio Azevedo'],
      year: 1890,
      subjects: ['romance', 'naturalismo', 'literatura brasileira'],
      description:
          'A vida em uma habitação coletiva do Rio de Janeiro, retratada '
          'como um organismo vivo movido por ambição, desejo e desigualdade.',
    ),
    AppBook(
      id: 'grande-sertao',
      title: 'Grande Sertão: Veredas',
      authors: ['João Guimarães Rosa'],
      year: 1956,
      subjects: ['romance', 'sertão', 'literatura brasileira'],
      description:
          'Riobaldo narra suas travessias pelo sertão, entre jagunços, '
          'amor e dúvidas sobre o bem e o mal, em uma linguagem inventiva.',
    ),
    AppBook(
      id: 'vidas-secas',
      title: 'Vidas Secas',
      authors: ['Graciliano Ramos'],
      year: 1938,
      subjects: ['romance', 'regionalismo', 'literatura brasileira'],
      description:
          'A família de Fabiano atravessa a seca do sertão nordestino em '
          'busca de sobrevivência e dignidade, em prosa enxuta e direta.',
    ),
    AppBook(
      id: 'hora-da-estrela',
      title: 'A Hora da Estrela',
      authors: ['Clarice Lispector'],
      year: 1977,
      subjects: ['romance', 'literatura brasileira'],
      description:
          'Macabéa, jovem nordestina no Rio de Janeiro, vive à margem de tudo, '
          'enquanto o narrador questiona o próprio ato de contar sua história.',
    ),
    AppBook(
      id: 'pequeno-principe',
      title: 'O Pequeno Príncipe',
      authors: ['Antoine de Saint-Exupéry'],
      year: 1943,
      subjects: ['fábula', 'infantil', 'fantasia', 'clássico'],
      description:
          'Um piloto perdido no deserto conhece um menino vindo de outro '
          'planeta e aprende com ele sobre amizade, amor e o essencial.',
    ),
    AppBook(
      id: '1984',
      title: '1984',
      authors: ['George Orwell'],
      year: 1949,
      subjects: ['ficção', 'distopia', 'política', 'clássico'],
      description:
          'Em um Estado que vigia tudo e reescreve a verdade, Winston Smith '
          'arrisca a vida ao tentar pensar por conta própria.',
    ),
    AppBook(
      id: 'orgulho-preconceito',
      title: 'Orgulho e Preconceito',
      authors: ['Jane Austen'],
      year: 1813,
      subjects: ['romance', 'clássico', 'ficção'],
      description:
          'Elizabeth Bennet e o senhor Darcy precisam superar julgamentos '
          'precipitados e diferenças sociais para reconhecer o que sentem.',
    ),
    AppBook(
      id: 'frankenstein',
      title: 'Frankenstein',
      authors: ['Mary Shelley'],
      year: 1818,
      subjects: ['ficção', 'terror', 'ficção científica', 'clássico'],
      description:
          'O cientista Victor Frankenstein dá vida a uma criatura e enfrenta '
          'as consequências de abandonar aquilo que criou.',
    ),
    AppBook(
      id: 'dracula',
      title: 'Drácula',
      authors: ['Bram Stoker'],
      year: 1897,
      subjects: ['ficção', 'terror', 'clássico', 'vampiros'],
      description:
          'Cartas e diários contam como um grupo de amigos se une para '
          'enfrentar o conde que ameaça Londres vindo da Transilvânia.',
    ),
    AppBook(
      id: 'o-hobbit',
      title: 'O Hobbit',
      authors: ['J. R. R. Tolkien'],
      year: 1937,
      subjects: ['fantasia', 'aventura', 'ficção'],
      description:
          'Bilbo Bolseiro deixa o conforto do Condado para acompanhar anões '
          'em uma jornada até a montanha guardada pelo dragão Smaug.',
    ),
    AppBook(
      id: 'alice',
      title: 'Alice no País das Maravilhas',
      authors: ['Lewis Carroll'],
      year: 1865,
      subjects: ['fantasia', 'infantil', 'clássico', 'ficção'],
      description:
          'Ao seguir um coelho branco, Alice cai em um mundo onde a lógica '
          'não funciona como de costume e tudo pode acontecer.',
    ),
    AppBook(
      id: 'crime-castigo',
      title: 'Crime e Castigo',
      authors: ['Fiódor Dostoiévski'],
      year: 1866,
      subjects: ['romance', 'psicológico', 'clássico', 'ficção'],
      description:
          'Raskólnikov comete um crime acreditando poder justificá-lo, mas '
          'a culpa e a consciência o perseguem pelas ruas de São Petersburgo.',
    ),
    AppBook(
      id: 'cem-anos',
      title: 'Cem Anos de Solidão',
      authors: ['Gabriel García Márquez'],
      year: 1967,
      subjects: ['romance', 'realismo mágico', 'ficção'],
      description:
          'A saga da família Buendía na cidade de Macondo mistura história, '
          'mito e fantasia ao longo de várias gerações.',
    ),
    AppBook(
      id: 'o-alquimista',
      title: 'O Alquimista',
      authors: ['Paulo Coelho'],
      year: 1988,
      subjects: ['ficção', 'aventura', 'fábula'],
      description:
          'O pastor Santiago parte em busca de um tesouro e descobre que a '
          'jornada importa tanto quanto o destino.',
    ),
  ];

  static String _norm(String s) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    var out = s.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  Future<List<AppBook>> listBooks() async => List<AppBook>.of(_livros);

  Future<List<AppBook>> searchBooks(String query) async {
    final q = _norm(query.trim());
    if (q.isEmpty) return listBooks();
    return _livros.where((book) {
      final text = _norm([
        book.title,
        ...book.authors,
        ...book.subjects,
        '${book.year ?? ''}',
      ].join(' '));
      return text.contains(q);
    }).toList();
  }

  Future<AppBook> getBook(String id) async {
    for (final book in _livros) {
      if (book.id == id) return book;
    }
    throw Exception('Detalhes do livro não encontrados.');
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
