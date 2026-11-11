## Context

Veja `proposal.md`. A proposta traz as interações avançadas da Netflix com foco em fluidez, responsividade desktop/web e identidade de marca.

## Decisions

### 1. Hero com Efeito Ken Burns & Barra de Progresso
- Substituir o timer estático por um `AnimationController` com duração de 6s para a barra de progresso do slide ativo.
- O slide exibe uma fileira de barras lineares no topo ou na base: os slides anteriores ficam 100% cheios, o slide atual anima de 0% a 100%, e os próximos ficam vazios.
- O widget de capa aplica um `ScaleTransition` sutil (1.0 -> 1.08) durante a exibição de cada slide (efeito Ken Burns), criando a sensação de um trailer/cena viva.
- Ao pressionar a tela (`GestureDetector`), a animação é pausada; ao soltar, continua.

### 2. Setas de Rolagem Lateral & Desktop Drag Scroll
- Em `BookShelfRow`, envolver o `ListView` horizontal em um `Stack` com dois botões laterais de navegação:
  - Seta Esquerda: visível apenas quando `scrollOffset > 10`.
  - Seta Direita: visível enquanto `scrollOffset < maxScrollExtent - 10`.
  - As setas têm fundo translúcido escuro, ícone chevron e disparam `scrollController.animateTo(offset +/- 400, duration: 400ms, curve: Curves.easeOutCubic)`.
  - Suporte a mouse drag via `ScrollConfiguration` com `MaterialScrollBehavior` que inclui `PointerDeviceKind.mouse` e `PointerDeviceKind.trackpad`.

### 3. Responsividade dos Cards
- Em `BookShelfRow`:
  - Largura de tela < 600px: cardWidth = 125px, cardHeight = 190px.
  - Largura de tela entre 600px e 1100px: cardWidth = 150px, cardHeight = 225px.
  - Largura de tela > 1100px: cardWidth = 175px, cardHeight = 265px.
  - Manter rigorosamente proporção 2:3 da capa em qualquer resolução.

### 4. Pílulas de Categoria no Topo da Home
- Na `CatalogScreen`, adicionar uma `SliverPersistentHeader` ou `SliverToBoxAdapter` logo abaixo da AppBar contendo os chips das categorias ("Todos", "Destaques", "Clássicos", ...).
- Ao clicar no chip, calcula o offset da prateleira selecionada e rola suavemente a `CustomScrollView` até a posição desejada com feedback tátil.

### 5. Animação "Tudum" Lúmen
- Um widget `LumenSplashTransition` entre o login e a home.
- Ao efetuar login, exibe o logo Lúmen centralizado em fundo quase-preto.
- O logo pulsa com brilho âmbar intenso (escala 0.8 -> 1.15 -> 1.0, com `RadialGradient` de luz âmbar irradiando atrás) acompanhado de som/haptic e dissolve revelando a tela inicial. Duração total: ~1.2s.
