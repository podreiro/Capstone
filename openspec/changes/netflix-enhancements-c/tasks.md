## 1. Responsividade Web & Rolagem com Setas

- [x] 1.1 Configurar suporte global a arrasto com mouse (drag scroll) em `lib/frontend/app.dart` via `ScrollBehavior`
- [x] 1.2 Atualizar `lib/frontend/widgets/book_shelf_row.dart` com cálculo responsivo de largura/altura dos cards baseado na largura da tela
- [x] 1.3 Adicionar setas laterais flutuantes (chevron esquerdo/direito) em `lib/frontend/widgets/book_shelf_row.dart` com rolagem suave ao clicar

## 2. Hero Mais Vivo (Ken Burns & Barra de Progresso)

- [x] 2.1 Refatorar `lib/frontend/widgets/hero_carousel.dart` com barras de progresso lineares segmentadas para cada slide
- [x] 2.2 Adicionar animação de zoom lento contínuo (Ken Burns) e leve parallax na capa durante a exibição do slide
- [x] 2.3 Manter pausa interativa perfeita ao pressionar/segurar o Hero

## 3. Pílulas de Categoria & Rolagem Ancorada

- [x] 3.1 Adicionar barra horizontal de chips de categorias no topo da `lib/frontend/screens/catalog_screen.dart`
- [x] 3.2 Implementar rolagem suave automática até a prateleira correspondente ao tocar em uma pílula

## 4. Animação de Entrada "Tudum Lúmen"

- [x] 4.1 Criar componente `lib/frontend/widgets/lumen_tudum_intro.dart` com pulso de luz âmbar e escala do logo
- [x] 4.2 Integrar a transição animada pós-login no `AuthGate` em `lib/frontend/app.dart`
