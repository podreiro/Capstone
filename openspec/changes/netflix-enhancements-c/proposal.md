## Why

Com a fundação visual e correções estruturais estabelecidas (Blocos A e B), esta mudança (Bloco C) adiciona interatividade avançada típica de plataformas de streaming premium (estilo Netflix):
- Animação cinematográfica de Hero com Ken Burns (zoom lento) e barras de progresso lineares.
- Setas laterais para scroll horizontal em prateleiras no desktop/web, arraste livre com mouse e cards responsivos.
- Pílulas/chips de navegação rápida por categoria no topo da tela inicial.
- Transição de entrada ("tudum" Lúmen) com o logo acendendo em luz âmbar ao autenticar.

## What Changes

- **Hero Animado com Ken Burns e Progresso Linear**: Barra de progresso para cada slide no carrossel, zoom sutil contínuo na capa e pausa interativa on-tap.
- **Setas de Rolagem Lateral & Arraste com Mouse**: Botões chevron flutuantes à esquerda e direita em cada prateleira com animação de hover/fade, e suporte a `ScrollBehavior` com arraste por mouse no navegador.
- **Cards Responsivos por Largura de Tela**: Cards e alturas de prateleira dimensionados de acordo com `MediaQuery.sizeOf(context).width`.
- **Barra de Pílulas de Categoria (Category Chips)**: Rolagem ancorada para cada seção do catálogo via `ScrollController` ou `GlobalKey`.
- **Efeito de Abertura "Tudum Lúmen"**: Transição suave pós-login onde a marca Lúmen pulsa em luz âmbar antes de revelar a tela principal.

## Capabilities

### New Capabilities
*(Nenhuma nova capability de especificação; puramente enriquecimento visual e interação)*

### Modified Capabilities
*(Nenhuma alteração de modelo de dados ou API)*

## Impact

- `lib/frontend/widgets/hero_carousel.dart`: Ken Burns zoom, barras de progresso lineares.
- `lib/frontend/widgets/book_shelf_row.dart`: setas de scroll laterais, dimensões responsivas.
- `lib/frontend/screens/catalog_screen.dart`: chips de categorias flutuantes no topo com rolagem até a seção.
- `lib/frontend/app.dart`: transição com splash animado Lúmen pós-login e `ScrollBehavior` customizado para drag no desktop.
