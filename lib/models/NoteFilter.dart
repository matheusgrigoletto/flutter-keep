import 'package:flutter/foundation.dart';
import 'Note.dart';

/// Contém o filtro de pesquisa atual de notas.
class NoteFilter extends ChangeNotifier {
  NoteState _noteState;

  /// Atualiza o [NoteState] do filtro
  set noteState(NoteState value) {
    if (value != null && value != _noteState) {
      _noteState = value;
    }
    notifyListeners();
  }

  /// O estado do filtro atual
  NoteState get noteState => _noteState;

  /// Cria um objeto [NoteFilter]
  NoteFilter([this._noteState = NoteState.unspecified]);
}
