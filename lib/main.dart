import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LumenApp());
}

enum ReadingTheme { creme, branco, noturno }

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

class LumenApp extends StatefulWidget {
  const LumenApp({super.key});

  @override
  State<LumenApp> createState() => _LumenAppState();
}

class _LumenAppState extends State<LumenApp> {
  ReadingTheme readingTheme = ReadingTheme.creme;

  ThemeData get theme {
    switch (readingTheme) {
      case ReadingTheme.creme:
        return _buildTheme(
          background: const Color(0xFFF6F0E2),
          surface: const Color(0xFFFFFBF2),
          primary: const Color(0xFF6D5135),
          text: const Color(0xFF3F342A),
        );
      case ReadingTheme.branco:
        return _buildTheme(
          background: const Color(0xFFF8F8F8),
          surface: Colors.white,
          primary: const Color(0xFF4A5568),
          text: const Color(0xFF202124),
        );
      case ReadingTheme.noturno:
        return _buildTheme(
          background: const Color(0xFF171513),
          surface: const Color(0xFF24201D),
          primary: const Color(0xFFD9B982),
          text: const Color(0xFFF2E9D8),
          brightness: Brightness.dark,
        );
    }
  }

  ThemeData _buildTheme({
    required Color background,
    required Color surface,
    required Color primary,
    required Color text,
    Brightness brightness = Brightness.light,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: primary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(
            bodyColor: text,
            displayColor: text,
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void setReadingTheme(ReadingTheme value) {
    setState(() => readingTheme = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lúmen',
      theme: theme,
      home: LoginPage(onThemeChanged: setReadingTheme),
    );
  }
}

class LoginPage extends StatefulWidget {
  final ValueChanged<ReadingTheme> onThemeChanged;

  const LoginPage({super.key, required this.onThemeChanged});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool isLogin = true;
  bool obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          userEmail: _email.text.trim(),
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.auto_stories_rounded, size: 68, color: color),
                    const SizedBox(height: 14),
                    Text(
                      'Lúmen',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seus livros, no seu ritmo e com mais conforto.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 38),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Entrar')),
                        ButtonSegment(value: false, label: Text('Cadastrar')),
                      ],
                      selected: {isLogin},
                      onSelectionChanged: (value) =>
                          setState(() => isLogin = value.first),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null ||
                            !value.contains('@') ||
                            !value.contains('.')) {
                          return 'Informe um e-mail válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: Icon(
                        isLogin ? Icons.login : Icons.person_add_alt_1,
                      ),
                      label: Text(isLogin ? 'Entrar' : 'Criar conta'),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Acesso demonstrativo: o formulário é validado localmente neste protótipo.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userEmail;
  final ValueChanged<ReadingTheme> onThemeChanged;

  const HomePage({
    super.key,
    required this.userEmail,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final service = OpenLibraryService();
  final store = LocalStore();

  @override
  Widget build(BuildContext context) {
    final pages = [
      CatalogPage(service: service, store: store),
      SearchPage(service: service, store: store),
      HistoryPage(service: service, store: store),
      ProfilePage(
        email: widget.userEmail,
        store: store,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Lendo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class CatalogPage extends StatefulWidget {
  final OpenLibraryService service;
  final LocalStore store;

  const CatalogPage({super.key, required this.service, required this.store});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<AppBook>> future;

  @override
  void initState() {
    super.initState();
    future = widget.service.searchBooks('fiction');
  }

  Future<void> refresh() async {
    setState(() => future = widget.service.searchBooks('fiction'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text(
                'Lúmen',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  tooltip: 'Buscar',
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encontre sua próxima história.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Uma biblioteca pensada para uma leitura mais tranquila.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<AppBook>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorState(onRetry: refresh),
                  );
                }
                final books = snapshot.data ?? [];
                if (books.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Nenhum livro encontrado.')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => BookCard(
                        book: books[i],
                        store: widget.store,
                      ),
                      childCount: books.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisExtent: 310,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final OpenLibraryService service;
  final LocalStore store;

  const SearchPage({super.key, required this.service, required this.store});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  Future<List<AppBook>>? result;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search() {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => result = widget.service.searchBooks(controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: const Text('Buscar livros')),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => search(),
                decoration: InputDecoration(
                  hintText: 'Nome do livro, autor ou assunto',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: search,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Digite pelo menos 2 caracteres.';
                  }
                  return null;
                },
              ),
            ),
          ),
          Expanded(
            child: result == null
                ? _SearchEmpty()
                : FutureBuilder<List<AppBook>>(
                    future: result,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return ErrorState(
                          onRetry: search,
                          message: 'Não foi possível realizar a busca.',
                        );
                      }
                      final books = snapshot.data ?? [];
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisExtent: 310,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: books.length,
                        itemBuilder: (_, i) => BookCard(
                          book: books[i],
                          store: widget.store,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  final OpenLibraryService service;
  final LocalStore store;

  const HistoryPage({super.key, required this.service, required this.store});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<AppBook>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<AppBook>> _load() async {
    final ids = (await widget.store.getHistory()).toList().reversed.toList();
    final books = <AppBook>[];
    for (final id in ids) {
      try {
        books.add(await widget.service.getBook(id));
      } catch (_) {}
    }
    return books;
  }

  void reload() => setState(() => future = _load());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: const Text('Estou lendo')),
          Expanded(
            child: FutureBuilder<List<AppBook>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorState(onRetry: reload);
                }
                final books = snapshot.data ?? [];
                if (books.isEmpty) {
                  return const EmptyState(
                    icon: Icons.auto_stories_outlined,
                    title: 'Sua estante está vazia',
                    message:
                        'Abra um livro para ele aparecer aqui e continue de onde parou.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => HistoryCard(book: books[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String email;
  final LocalStore store;
  final ValueChanged<ReadingTheme> onThemeChanged;

  const ProfilePage({
    super.key,
    required this.email,
    required this.store,
    required this.onThemeChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ReadingTheme selected = ReadingTheme.creme;

  String themeLabel(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.creme:
        return 'Creme — leitura longa';
      case ReadingTheme.branco:
        return 'Branco — leitura objetiva';
      case ReadingTheme.noturno:
        return 'Noturno — baixa luminosidade';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppBar(title: const Text('Meu perfil')),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 26,
                child: Text(
                  widget.email.isNotEmpty ? widget.email[0].toUpperCase() : 'L',
                ),
              ),
              title: const Text(
                'Leitor Lúmen',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(widget.email),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Conforto de leitura',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha a aparência que combina com seu momento de leitura.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ...ReadingTheme.values.map(
            (theme) => RadioListTile<ReadingTheme>(
              value: theme,
              groupValue: selected,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selected = value);
                widget.onThemeChanged(value);
              },
              title: Text(themeLabel(theme)),
              subtitle: Text(
                theme == ReadingTheme.creme
                    ? 'Contraste suave, inspirado no papel creme.'
                    : theme == ReadingTheme.branco
                        ? 'Maior contraste para estudos e consultas rápidas.'
                        : 'Fundo escuro e texto suave para ambientes com pouca luz.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: const ListTile(
              leading: Icon(Icons.favorite_outline),
              title: Text('Favoritos'),
              subtitle: Text(
                'Os IDs dos seus favoritos são armazenados localmente.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: const ListTile(
              leading: Icon(Icons.history),
              title: Text('Histórico'),
              subtitle: Text(
                'Seus livros iniciados ficam disponíveis na aba “Lendo”.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookCard extends StatefulWidget {
  final AppBook book;
  final LocalStore store;

  const BookCard({super.key, required this.book, required this.store});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final ids = await widget.store.getFavorites();
    if (mounted) setState(() => favorite = ids.contains(widget.book.id));
  }

  Future<void> _toggleFavorite() async {
    await widget.store.toggleFavorite(widget.book.id);
    if (mounted) setState(() => favorite = !favorite);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookDetailPage(
            book: widget.book,
            service: OpenLibraryService(),
            store: widget.store,
          ),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BookCover(url: widget.book.coverUrl),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withOpacity(.42),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: favorite ? 'Remover favorito' : 'Favoritar',
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                widget.book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                widget.book.authors.isEmpty
                    ? 'Autor desconhecido'
                    : widget.book.authors.take(2).join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailPage extends StatefulWidget {
  final AppBook book;
  final OpenLibraryService service;
  final LocalStore store;

  const BookDetailPage({
    super.key,
    required this.book,
    required this.service,
    required this.store,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<AppBook> future;
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    future = widget.service.getBook(widget.book.id);
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final ids = await widget.store.getFavorites();
    if (mounted) setState(() => favorite = ids.contains(widget.book.id));
  }

  Future<void> _toggleFavorite() async {
    await widget.store.toggleFavorite(widget.book.id);
    if (mounted) setState(() => favorite = !favorite);
  }

  Future<void> _startReading() async {
    await widget.store.addHistory(widget.book.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro adicionado à sua lista de leitura.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do livro'),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: FutureBuilder<AppBook>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              onRetry: () => setState(
                () => future = widget.service.getBook(widget.book.id),
              ),
            );
          }

          final book = snapshot.data ?? widget.book;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(
                child: SizedBox(
                  height: 330,
                  width: 220,
                  child: BookCover(url: book.coverUrl),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                book.authors.isEmpty
                    ? 'Autor desconhecido'
                    : book.authors.join(', '),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (book.year != null) ...[
                const SizedBox(height: 4),
                Text('Publicação: ${book.year}'),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _startReading,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Começar leitura'),
              ),
              const SizedBox(height: 24),
              Text(
                'Sobre o livro',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                book.description?.trim().isNotEmpty == true
                    ? book.description!
                    : 'Não há descrição disponível para este título na Open Library.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final AppBook book;

  const HistoryCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(
          width: 52,
          height: 72,
          child: BookCover(url: book.coverUrl),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          book.authors.isEmpty ? 'Autor desconhecido' : book.authors.join(', '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  final String? url;

  const BookCover({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.menu_book_rounded, size: 48),
      );
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.menu_book_rounded, size: 48),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}

class ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const ErrorState({
    super.key,
    required this.onRetry,
    this.message = 'Não foi possível carregar os livros.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.manage_search_rounded,
      title: 'O que você quer ler?',
      message: 'Pesquise por título, autor ou assunto para encontrar seu próximo livro.',
    );
  }
}
