## Why

O Lúmen tem uma base funcional sólida, mas o design atual usa o Material 3 padrão sem identidade visual própria. O app de leitura merece uma experiência contemporânea e atrativa — com dark theme editorial, tipografia com personalidade e layout inspirado em plataformas de streaming — para que a descoberta de livros seja tão prazerosa quanto a leitura.

## What Changes

- Novo dark theme com paleta âmbar-noir (fundo quase-preto, acento dourado remetendo ao nome "Lúmen")
- Tipografia aprimorada: títulos em Playfair Display (serifada dramática), UI em Inter (sans-serif moderna)
- Tela Início reformulada: hero fullscreen com carrossel automático + linhas horizontais por categoria (estilo Netflix)
- BookCard redesenhado: apenas capa com proporção 2:3, título e autor sobrepostos via gradiente
- BookDetail com capa full-bleed no topo, barra de ações transparente e conteúdo em sheet abaixo
- Login com fundo escuro, logo âmbar e tipografia editorial
- NavigationBar inferior escura, ícones mais finos
- Adicionar dependência `google_fonts`

## Capabilities

### New Capabilities

*(Nenhuma nova capability de comportamento — redesign puramente visual)*

### Modified Capabilities

*(Nenhuma mudança de requisitos — apenas apresentação)*

> **Nota:** Este é um redesign puramente visual (tema, layout de widgets, tipografia). Nenhum provider, model, service ou regra de negócio é alterado. `skip_specs: true` será definido no `.openspec.yaml`.

## Impact

- `pubspec.yaml` — adicionar `google_fonts: ^6.2.1`
- `lib/frontend/theme/app_theme.dart` — nova paleta e tipografia
- `lib/frontend/screens/home_screen.dart` — ajuste da nav bar
- `lib/frontend/screens/catalog_screen.dart` — hero + carrossel + linhas horizontais
- `lib/frontend/screens/book_detail_screen.dart` — full-bleed hero + layout reformulado
- `lib/frontend/screens/login_screen.dart` — dark background + identidade editorial
- `lib/frontend/widgets/book_card.dart` — card sem fundo, capa com overlay
- `lib/frontend/widgets/book_cover.dart` — suporte a aspect ratio 2:3
- `lib/frontend/widgets/paged_book_grid.dart` — substituído por `paged_book_row.dart` (scroll horizontal)
- Nenhuma mudança em `backend/`
