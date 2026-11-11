## 1. Fundação e Correções Estruturais (Bloco A)

- [x] 1.1 Criar `LumenColors` (ThemeExtension) em `lib/frontend/theme/app_theme.dart` com tokens para dark e creme, e disponibilizar getter `context.lumen`
- [x] 1.2 Atualizar `lib/frontend/screens/home_screen.dart` para usar `context.lumen` nas cores de fundo, bordas e NavigationBar
- [x] 1.3 Atualizar `lib/frontend/screens/catalog_screen.dart` para usar `context.lumen`
- [x] 1.4 Atualizar `lib/frontend/screens/book_detail_screen.dart` para usar `context.lumen`
- [x] 1.5 Atualizar `lib/frontend/screens/login_screen.dart` para usar `context.lumen`
- [x] 1.6 Atualizar `lib/frontend/screens/profile_screen.dart` para usar `context.lumen`
- [x] 1.7 Atualizar `lib/frontend/widgets/book_card.dart`, `book_list_tile.dart` e `state_views.dart` para usar `context.lumen`
- [x] 1.8 Remover a pasta legada `lib/Paginas/` e seus arquivos
- [x] 1.9 Otimizar requisições: remover `CatalogProvider(api)..reload()` no `main.dart` e implementar `ensureLoaded()` preguiçoso no `ShelfProvider` e `CatalogScreen`
- [x] 1.10 Aumentar tipografia e contraste nos cards em `book_card.dart` (título 13px e autor 11px)

## 2. Inovações Visuais Estilo Streaming (Bloco B)

- [x] 2.1 Refatorar `lib/frontend/widgets/hero_carousel.dart` para usar fundo desfocado (`ImageFiltered`) e capa central nítida com aspecto 2:3 e elevação
- [x] 2.2 Criar widget de skeleton shimmer nativo em `lib/frontend/widgets/state_views.dart` e aplicar placeholders nas prateleiras e hero
- [x] 2.3 Implementar estilo Top 10 com numerais gigantes na prateleira "Destaques" em `lib/frontend/widgets/book_shelf_row.dart`
- [x] 2.4 Adicionar animação `Hero` na capa do livro conectando o `BookCard` à `BookDetailScreen`
- [x] 2.5 Adicionar microinteração com animação de escala e toque háptico ao botão de favoritar no card
