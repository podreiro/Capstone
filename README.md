# Lúmen — Biblioteca de livros online


Projeto final esta na develop. 

## 1. Identificação

| Item | Informação |
|---|---|
| **App** | Lúmen |
| **Squad** | Foorteen Books |
| **Disciplina** | Desenvolvimento para Ambientes Móveis (Flutter) — Entrega final A3 |
| **Instituição** | Faculdade Cotemig |

| Integrante | Matrícula | Contato |
|---|---|---|
| Jade Schoenstatt (líder) | 72501146 | 72501146@aluno.faculdadecotemig.br |
| Rafael Barbieri | 72500310 | 72500310@aluno.faculdadecotemig.br |
| Pedro Henrique Vivas | 72500093 |72500093@aluno.faculdadecotemig.br |
| Rubens Gabriel | 72501123 | 72501123@aluno.faculdadecotemig.br |

## 2. Sobre o projeto

O **Lúmen** é um app para quem quer ler livros pelo celular ou navegador: "ler os seus livros na palma da mão".
O público são leitores em geral, em especial quem busca obras de domínio público e edições digitais gratuitas.
O usuário cria uma conta (com confirmação de senha) ou entra, e cai no **grid de livros** por categoria
(Destaques, Clássicos, Ficção, Fantasia etc.), com rolagem infinita. Na aba **Buscar**, pesquisa por título, autor
ou assunto (formulário validado) e pode filtrar apenas livros com leitura online. Ao tocar em um livro, abre
a tela de **Detalhes** (capa, autor, ano, assuntos, descrição e o **link para ler o livro**). O botão **Ler agora**
abre a leitura e salva o livro na aba **Lendo**. O usuário também pode **favoritar** livros e escolher o tema de
leitura (creme, branco ou noturno) na tela de **Perfil**. Favoritos, histórico e tema ficam salvos no aparelho
e continuam ao reabrir o app.

**Telas:** Login/Cadastro → Início (grid) · Buscar · Lendo · Perfil (abas) → Detalhes do livro · Favoritos · Sobre.

## 3. Requisitos atendidos

| # | Requisito | Onde está no app |
|---|---|---|
| 1 | Telas com `Navigator.push` e `pop` | 7 telas no total. `Navigator.push` para **Detalhes** (`BookDetailScreen.open`, a partir dos cards do grid, da busca, de "Lendo" e de "Favoritos"), **Favoritos** (`FavoritesScreen.open`) e **Sobre** (`AboutScreen.open`), todos acionados pelo Perfil/grids; o botão voltar faz o `pop`. Arquivos em `lib/frontend/screens/`. |
| 2 | API REST com `http` e `async/await` | `lib/backend/services/open_library_service.dart` (Open Library). Nenhum dado fixo no código. |
| 3 | Loading e erro visíveis na UI | `lib/frontend/widgets/state_views.dart` (`LoadingView`, `ErrorState`, `ErrorBanner`) usados no grid, busca, detalhes, "Lendo" e "Favoritos", com botão **Tentar novamente**. |
| 4 | Formulário com `Form` e `validator` | `login_screen.dart` (e-mail, senha, confirmação de senha) e `search_screen.dart` (mínimo de 2 caracteres). |
| 5 | Lista dinâmica com `ListView.builder` | `reading_screen.dart` e `favorites_screen.dart` (`ListView.builder`); grids com `GridView.builder` em `paged_book_grid.dart`. |
| 6 | `SharedPreferences` persiste ao reabrir | `lib/backend/services/local_storage_service.dart`: contas, IDs dos favoritos (`favorites_<email>`), IDs do histórico (`historyPreferences_<email>`) e tema de leitura. |
| 7 | Provider: telas, HTTP e prefs separados | Telas em `lib/frontend/`; HTTP em `backend/services/open_library_service.dart`; prefs em `backend/services/local_storage_service.dart`; estado em `backend/providers/` (`AuthProvider`, `CatalogProvider`, `SearchProvider`, `LibraryProvider`, `BookDetailProvider`, `ThemeProvider`). |
| 8 | App abre e percorre o fluxo sem crashar | Fluxo: cadastro → grid → detalhes → ler/favoritar → "Lendo"/Favoritos → reabrir app. Erros de rede são tratados e exibidos (sem exceções soltas). |

**Bônus entregues:** `url_launcher` (abre o link de leitura), três temas de leitura (claro/escuro) e rolagem infinita.

## 4. API e dados remotos

**API pública** (Open Library), sem chave e sem login de teste.

- **URL base:** `https://openlibrary.org`
- **Documentação:** <https://openlibrary.org/dev/docs/api/search>

| Uso | Método e endpoint |
|---|---|
| Lista, catálogo por categoria e busca | `GET /search.json?q=<termo>&page=<n>&limit=24&fields=...` |
| Detalhes (descrição e assuntos) | `GET /works/<ID>.json` (ex.: `/works/OL45883W.json`) |
| Capas | `https://covers.openlibrary.org/b/id/<cover_i>-M.jpg` |

**Link para ler o livro:** vem do campo `ia` (identificador do Internet Archive) e de `ebook_access` retornados pela busca.
Quando há edição digital, o app monta `https://archive.org/details/<ia>`; senão, abre a página da obra na Open Library.

**Dados locais (SharedPreferences):** contas, IDs dos favoritos, IDs do histórico de leitura e tema escolhido.

**Acesso de teste:** não há usuário pré-criado. Use **Cadastrar** na tela inicial para criar uma conta (ela fica salva só no aparelho/navegador).

## 5. Como rodar

Pré-requisitos: Flutter SDK 3.x estável (Dart ≥ 3.3) — confira com `flutter --version` e **ajuste aqui a versão usada pelo squad**.
Plataformas: Web (Chrome) e Android — **ajuste conforme o que o squad testou**.

```bash
flutter pub get
flutter run -d chrome      # ou: flutter run  (emulador/aparelho Android)
```

As dependências estão no `pubspec.yaml`: `http`, `provider`, `shared_preferences`, `url_launcher` e `crypto`.
É necessário acesso à internet para consumir a API.

## 6. Backend local

Não há backend local: o app consome apenas a **API pública** da Open Library (ver seção 4).

## 7. Estrutura do código

```text
lib/
├── main.dart                     # ponto de entrada e injeção dos providers
├── backend/                      # dados e regras (sem widgets)
│   ├── models/book.dart          # modelo Book e leitura do JSON da API
│   ├── services/
│   │   ├── open_library_service.dart    # cliente HTTP (http + async/await)
│   │   └── local_storage_service.dart   # SharedPreferences
│   └── providers/                # estado (ChangeNotifier): auth, catálogo, busca,
│                                 # biblioteca (favoritos/histórico), detalhes, tema
└── frontend/                     # interface
    ├── app.dart                  # MaterialApp e controle de sessão (login)
    ├── theme/app_theme.dart      # temas creme, branco e noturno
    ├── screens/                  # login, home, catálogo, busca, lendo, perfil,
    │                             # favoritos, detalhes e sobre
    └── widgets/                  # cards, capa, grid paginado, estados de loading/erro
```

## 8. Observações

- **Sessão:** o login fica apenas em memória; ao recarregar a página (F5) ou reabrir o app, volta para a tela de login.
  As contas e os dados de cada usuário continuam salvos no aparelho.
- **Contas locais:** a autenticação é didática (sem servidor). A senha é guardada como hash (SHA-256) no `SharedPreferences`.
- **Compras:** o app não tem fluxo de compra; o perfil mostra favoritos e livros em leitura.
- **Leitura online:** nem todo livro tem edição digital; alguns exigem conta gratuita no Internet Archive para empréstimo.
- **Dependência da API:** a Open Library pode ficar lenta ou indisponível; nesse caso o app mostra a mensagem de erro e permite tentar novamente.
- **Capas na web:** se alguma capa não carregar no navegador, o app exibe um ícone no lugar.
- **Não deu tempo / ideias futuras:** continuar leitura do ponto onde parou, compra de livros, login com servidor.
