## Why

O redesign visual inicial estabeleceu a linguagem contemporânea estilo Netflix, mas introduziu inconsistências:
1. Cores fixas em quase todas as telas impedem o funcionamento do tema Creme.
2. O diretório legado `lib/Paginas/` contém código quebrado não utilizado.
3. A tela inicial dispara requisições concorrentes excessivas à API da Open Library na inicialização.
4. O visual do Hero corta capas em telas largas e faltam elementos icônicos de streaming (Top 10 com numerais gigantes, skeletons shimmer e transições Hero de capa).

Esta mudança resolve essas pendências estruturais (Bloco A) e eleva a experiência visual (Bloco B).

## What Changes

- **ThemeExtension para Suporte Completo a Temas**: Centralização dos tokens de cor (`bg`, `surface`, `card`, `border`, `accent`, `textPrimary`, `textMuted`) em uma `ThemeExtension<LumenColors>` para que o tema Creme volte a funcionar perfeitamente em todas as telas.
- **Limpeza de Código Morto**: Exclusão definitiva da pasta obsoleta `lib/Paginas/`.
- **Lazy Loading de Prateleiras & Performance de Rede**: Remoção da recarga não utilizada de `CatalogProvider` no `main.dart` e carregamento preguiçoso de cada prateleira (`ensureLoaded`) quando ela entra na área visível.
- **Tipografia e Contraste nos Cards**: Aumento de fontes (11px -> 13px para títulos, 9.5px -> 11px para autor) para melhor legibilidade.
- **Hero Cinematográfico**: Capa 2:3 nítida em destaque central sobre plano de fundo expandido com desfoque gaussiano (`ImageFiltered`) e gradientes suaves.
- **Top 10 Netflix**: Numerais gigantes elegantes posicionados com profundidade atrás dos cards na prateleira de "Destaques".
- **Skeleton Shimmer**: Placeholders animados elegantes substituindo os spinners circulares durante carregamentos.
- **Transição Hero nas Capas**: Animação fluida da capa do livro ao navegar entre o card da prateleira e a tela de detalhes.
- **Microinteração de Favoritos**: Efeito de escala pulsante e haptic feedback ao favoritar livros.

## Capabilities

### New Capabilities
*(Nenhuma nova capability de especificação - refatoração de frontend e enriquecimento de UI/UX)*

### Modified Capabilities
*(Nenhuma mudança de regra de negócio; `skip_specs: true` ativo)*

## Impact

- `lib/frontend/theme/app_theme.dart`: introdução de `LumenColors` (ThemeExtension).
- `lib/frontend/screens/*`: substituição de cores fixas por `context.lumen.*`.
- `lib/Paginas/*`: exclusão dos arquivos legados.
- `lib/main.dart` & `lib/backend/providers/catalog_provider.dart`: lazy loading de prateleiras.
- `lib/frontend/widgets/hero_carousel.dart`: camada nítida sobre fundo desfocado.
- `lib/frontend/widgets/book_shelf_row.dart`: suporte a modo Top 10 com números gigantes.
- `lib/frontend/widgets/book_card.dart`: Hero widget, fontes ajustadas e animação de favorito.
- `lib/frontend/widgets/state_views.dart`: componentes de Shimmer para cards e prateleiras.
