import 'package:flutter/foundation.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/services/open_library_service.dart';

/// Estado da tela de detalhes (um provider por tela aberta).
class BookDetailProvider extends ChangeNotifier {
  BookDetailProvider(this._service, this._book);

  final OpenLibraryService _service;
  Book _book;
  bool _loading = false;
  String? _error;
  bool _disposed = false;

  Book get book => _book;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _book = await _service.fetchDetails(_book);
    } on ApiException catch (e) {
      _error = e.message;
    }
    _loading = false;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
