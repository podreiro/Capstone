## Context

O Lúmen é um app Flutter (Material 3) que consome a Open Library API. O redesign é puramente visual: zero alterações em providers, models ou services. Veja `proposal.md` para a motivação completa.

Arquivos de UI envolvidos: `app_theme.dart`, `home_screen.dart`, `catalog_screen.dart`, `book_detail_screen.dart`, `login_screen.dart`, `book_card.dart`, `book_cover.dart`, `paged_book_grid.dart`.

## Goals / Non-Goals

**Goals:**
- Dark theme editorial com paleta âmbar-noir
- Tipografia com personalidade (Playfair Display + Inter via `google_fonts`)
- Home screen com hero fullscreen em carrossel automático + linhas horizontais por categoria
- BookCard minimalista: apenas capa com overlay de gradiente
- BookDetail com capa full-bleed no topo
- Login com identidade visual escura e editorial

**Non-Goals:**
- Nenhuma mudança em lógica de negócio, providers, models ou services
- Sem novas features (progresso de leitura real, dominant color extractor, etc.)
- Sem mudança na estrutura de navegação (mantém as 4 abas)

## Decisions

### 1. Paleta: Âmbar-Noir
**Decisão:** `bg #0A0A0F`, `surface #141420`, `accent #E8A838`, `text #F0EDE8`

**Rationale:** O nome "Lúmen" (luz) pede um acento luminoso. Âmbar dourado sobre fundo quase-preto cria alto contraste e remetente a luz de vela — coerente com o universo editorial. Alternativas consideradas:
- Roxo editorial (#9B59B6): mais genérico, sem conexão semântica com o nome
- Esmeralda (#00B894): atraente mas mais ligado a finance/saúde apps

### 2. Tipografia: Playfair Display + Inter via google_fonts
**Decisão:** `google_fonts: ^6.2.1` — Playfair Display para títulos de livros e hero; Inter para todo o resto da UI.

**Rationale:** Playfair Display é serifada dramática, muito usada em editoriais de prestígio (The New Yorker, etc.). Inter é a sans-serif mais legível para UI digital. Alternativas:
- Usar fonte local (assets): mais controle, mas mais trabalho e tamanho do bundle
- Lora: boa serifada mas menos impactante que Playfair no hero

### 3. Home: Hero em Carrossel + Linhas Horizontais
**Decisão:** A tela Início terá um `PageView` automático como hero (troca a cada 5s com indicadores) mostrando livros do catálogo atual. Abaixo, cada categoria do `CatalogProvider` vira uma seção com título e `ListView` horizontal.

**Rationale:** Elimina o `ChoiceChip` de categorias e o grid vertical — o usuário vê várias categorias ao mesmo tempo ao rolar, como Netflix. O hero usa livros já carregados (sem nova requisição). PageView com `AutomaticKeepAliveClientMixin` evita flicker.

**Alternativa considerada:** Carrossel de um único livro destacado fixo. Rejeitado — menos dinâmico, perde o efeito "app vivo".

### 4. BookCard: Capa com Overlay, sem Card Material
**Decisão:** Remover o `Card` widget. O card novo é apenas a `BookCover` com `AspectRatio(2/3)` + `Stack` com gradiente no rodapé + título/autor em `Text` branco.

**Rationale:** As capas das Open Library já são visualmente ricas. Adicionar um fundo de card branco/escuro compete com elas. O overlay minimalista deixa a capa respirar.

### 5. BookDetail: Full-bleed + SliverAppBar
**Decisão:** Usar `CustomScrollView` com `SliverAppBar(expandedHeight: 380, flexibleSpace: FlexibleSpaceBar)` mostrando a capa. A `SliverAppBar` fica transparente quando expandida e escura quando colapsada (preservando o botão voltar).

**Rationale:** É o padrão de apps de entretenimento premium (Spotify, Apple Music, Netflix). Requer apenas mudança de Scaffold+ListView para CustomScrollView+SliverList.

### 6. Login: Fundo escuro com tela dividida
**Decisão:** Manter a lógica do formulário idêntica, mas usar o dark theme também na tela de login (sem tema separado). Adicionar uma arte de fundo abstrata com um `Container` decorado com gradiente diagonal âmbar/preto.

## Risks / Trade-offs

| Risco | Mitigação |
|---|---|
| `google_fonts` baixa fontes na primeira run; pode falhar offline | Fontes ficam em cache após primeira uso. Fallback é a fonte do sistema. |
| `PageView` no hero aumenta complexidade do `CatalogScreen` | Extrair para widget `HeroCarousel` próprio — isolado e testável |
| `SliverAppBar` pode conflitar com o estado atual de `BookDetailScreen` | É uma mudança de layout apenas; lógica do `BookDetailProvider` não muda |
| Capas pequenas ficam pixeladas no hero fullscreen | Usar `largeCoverUrl` (tamanho L da API) no hero e cards normais |
| Texto branco sobre capas claras: baixo contraste | Gradiente escuro obrigatório no rodapé de todo card/hero; fallback: sombra de texto |

## Migration Plan

Sem migration plan necessário — mudanças são apenas de UI local. Nenhum dado persistido (SharedPreferences) é afetado. Rollback = reverter os arquivos de UI.
