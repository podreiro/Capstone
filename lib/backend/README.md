# Backend (camada de dados do Lúmen)

Tudo que não é tela fica aqui; as telas só conversam com os Providers (`lib/providers`).

- `models/book.dart` — modelo `AppBook` (parse do JSON da Open Library e do cache local).
- `services/open_library_service.dart` — HTTP (`http` + `async/await`):
  - `GET https://openlibrary.org/search.json?q=...` (catálogo e busca)
  - `GET https://openlibrary.org/works/{id}.json` (detalhes/descrição)
  - Tratamento de timeout, status != 200, JSON inválido e falta de conexão (`ApiException`).
- `services/local_store.dart` — SharedPreferences: favoritos, histórico, usuários, sessão e tema.
