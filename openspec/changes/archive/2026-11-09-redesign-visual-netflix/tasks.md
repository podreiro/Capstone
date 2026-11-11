## 1. Dependências

- [x] 1.1 Adicionar `google_fonts: ^6.2.1` ao `pubspec.yaml` e rodar `flutter pub get`

## 2. Tema Global

- [x] 2.1 Reescrever `lib/frontend/theme/app_theme.dart` com paleta âmbar-noir (bg `#0A0A0F`, surface `#141420`, accent `#E8A838`, text `#F0EDE8`) e integrar `google_fonts` (Playfair Display para displayLarge/headlineLarge, Inter para o restante)
- [x] 2.2 Atualizar o tema noturno existente para usar a mesma paleta âmbar-noir (unificar em um único dark theme elegante em vez de três temas separados)

## 3. Widget BookCard

- [x] 3.1 Reescrever `lib/frontend/widgets/book_card.dart`: remover `Card` Material, usar apenas `BookCover` com `AspectRatio(2/3)` + `Stack` com gradiente no rodapé + título/autor em `Text` branco sobreposto
- [x] 3.2 Adicionar botão de favorito (ícone coração) no canto superior direito do card com fundo semitransparente

## 4. Home Screen — Hero Carrossel + Linhas Horizontais

- [x] 4.1 Criar widget `lib/frontend/widgets/hero_carousel.dart`: `PageView` com `Timer` automático a cada 5s, indicadores de ponto na base, mostrando os primeiros 5 livros do catálogo (capa full-width + gradiente + título + autor + botões "Ler agora" e "Favoritar")
- [x] 4.2 Criar widget `lib/frontend/widgets/book_shelf_row.dart`: linha horizontal com título de seção + `ListView` horizontal de `BookCard` (altura fixa ~220px, cards com largura ~130px)
- [x] 4.3 Reescrever `lib/frontend/screens/catalog_screen.dart`: substituir AppBar+chips+grid por `CustomScrollView` com `SliverToBoxAdapter` para o `HeroCarousel` no topo + `SliverList` de `BookShelfRow` (uma por categoria do `CatalogProvider`)

## 5. BookDetail Screen

- [x] 5.1 Reescrever `lib/frontend/screens/book_detail_screen.dart`: substituir `Scaffold`+`ListView` por `CustomScrollView` com `SliverAppBar(expandedHeight: 380, pinned: true, flexibleSpace: FlexibleSpaceBar)` mostrando `BookCover` large como fundo; conteúdo (título, autor, chips, `_ReadCard`, descrição) em `SliverPadding`+`SliverList` abaixo

## 6. Login Screen

- [x] 6.1 Atualizar `lib/frontend/screens/login_screen.dart`: adicionar fundo escuro com gradiente diagonal âmbar/preto via `BoxDecoration`, aumentar o logotipo e aplicar `Playfair Display` ao título "Lúmen"

## 7. Navigation Bar

- [x] 7.1 Atualizar `lib/frontend/screens/home_screen.dart`: remover o ícone de busca na nav (já tem aba Buscar), ajustar visual da `NavigationBar` para ficar integrada ao dark theme

## 8. Ajustes Finais

- [x] 8.1 Revisar `lib/frontend/widgets/book_cover.dart` para garantir suporte a aspect ratio variável e placeholder coerente com o dark theme
- [x] 8.2 Atualizar `lib/frontend/widgets/state_views.dart` (LoadingView, ErrorState, EmptyState) para alinhar cores e tipografia ao novo tema
- [x] 8.3 Executar o app no Chrome e validar visualmente todas as telas; corrigir eventuais overflow ou contraste insuficiente
