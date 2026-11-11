## Context

Veja `proposal.md`. As alterações são estritamente de frontend e layout, mantendo a arquitetura de providers e serviços intocada.

## Goals / Non-Goals

**Goals:**
- Restaurar 100% da integridade visual do tema Creme e Noturno via `ThemeExtension`.
- Eliminar o código quebrado da pasta `lib/Paginas/`.
- Reduzir as requisições iniciais de 9 para 1 ou 2, com lazy loading nas prateleiras subsequentes.
- Entregar acabamento de streaming no Hero (desfoque de fundo + capa nítida) e prateleira Top 10 com números estilizados.
- Substituir spinners por skeleton shimmer placeholders e adicionar transição Hero na capa.

**Non-Goals:**
- Não alterar APIs, models nem o banco de dados/SharedPreferences local.
- Não introduzir pacotes externos pesados se soluções nativas do Flutter resolverem com alta qualidade e sem dependências extras.

## Decisions

### 1. ThemeExtension `LumenColors`
- Criar a classe `LumenColors extends ThemeExtension<LumenColors>` com propriedades:
  - `bg`: cor do Scaffold e fundo geral.
  - `surface`: fundo de cards elevados, modais e bottom bar.
  - `card`: cartões e caixas de formulário.
  - `border`: bordas e separadores sutis.
  - `accent`: cor principal de ação (ouro âmbar no escuro, marrom rico no creme).
  - `textPrimary`: cor de leitura principal.
  - `textMuted`: legendas e metadados.
- Extension helper `extension LumenContext on BuildContext { LumenColors get lumen => Theme.of(this).extension<LumenColors>()!; }`.
- Configurar instâncias para `ReadingTheme.noturno` e `ReadingTheme.creme`.

### 2. Otimização de Rede & Lazy Shelf Loading
- No `ShelfProvider`, remover a chamada imediata `reload()` no construtor.
- Adicionar o método `ensureLoaded()`: se já estiver carregado ou carregando, não faz nada; caso contrário, dispara `reload()`.
- Na `CatalogScreen`, carregar a primeira prateleira ("Destaques") imediatamente no `initState` para alimentar o Hero e a primeira linha.
- As demais prateleiras disparam `shelf.ensureLoaded()` assim que o item da `SliverList` é construído ou visualizado.
- Remover o `CatalogProvider(api)..reload()` desnecessário de `main.dart`.

### 3. Hero Visual com Capa Nítida sobre Fundo Blur
- O `HeroCarousel` exibe no fundo a capa do livro com `fit: BoxFit.cover` sob `ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25))` escurecida com `Colors.black54`.
- Em primeiro plano, uma capa centralizada mantendo rigorosamente o aspecto 2:3, com cantos arredondados e sombra de profundidade (`BoxShadow(blurRadius: 20, color: Colors.black87)`).
- Gradiente na base garantindo leitura perfeita dos textos e botões de ação.

### 4. Prateleira Top 10 com Numerais Gigantes
- Para a prateleira "Destaques", ativar a flag `isTop10: true`.
- Os itens exibem um número de 1 a 10 em tipografia de impacto (Playfair Display / Inter bold 90px), posicionado parcialmente atrás da capa (usando `Stack` com deslocamento à esquerda).
- Os cards mantêm o clique para detalhes.

### 5. Skeleton Shimmer Simples e Nativo
- Widget `ShimmerBox` construído com `AnimatedBuilder` sobre `LinearGradient` deslizante.
- Não requer dependência externa adicional e funciona tanto no tema escuro quanto no creme.

### 6. Transição Hero
- Envolver a capa em `BookCard` com `Hero(tag: 'book-cover-${book.id}', child: ...)` e replicar na `BookDetailScreen`.

## Risks / Trade-offs

- [Desfoque em dispositivos de baixo desempenho] → `ImageFilter.blur` com sigma moderado (20-25) é amplamente acelerado por GPU no Flutter moderno.
- [Conflito de Hero tag ao exibir o mesmo livro em duas prateleiras] → Usar tag contextualizada como `'book-cover-${shelfTitle}-${book.id}'` ou `'hero-cover-${book.id}'`.
