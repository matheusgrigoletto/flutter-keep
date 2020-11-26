import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_keep/services.dart' show NoteQuery;

/// Modelo de uma Nota
class Note extends ChangeNotifier {
  final String id;
  String title;
  String content;
  Color color;
  NoteState state;
  final DateTime createdAt;
  DateTime modifiedAt;

  /// Instancia uma [Note].
  Note({
    this.id,
    this.title,
    this.content,
    this.color,
    this.state,
    DateTime createdAt,
    DateTime modifiedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
        this.modifiedAt = modifiedAt ?? DateTime.now();

  @override
  bool operator ==(other) => other is Note &&
      (other.id ?? '') == (id ?? '') &&
      (other.title ?? '') == (title ?? '') &&
      (other.content ?? '') == (content ?? '') &&
      other.stateValue == stateValue &&
      (other.color ?? 0) == (color ?? 0);

  @override
  int get hashCode => id?.hashCode ?? super.hashCode;

  /// Se a nota está fixada
  bool get pinned => state == NoteState.pinned;

  /// Retorna uma forma numérica do estado
  int get stateValue => (state ?? NoteState.unspecified).index;

  /// Indica se uma Nota não está vazia
  bool get isNotEmpty => title?.isNotEmpty == true || content?.isNotEmpty == true;

  /// Formata string [modifiedAt]
  String get strLastModified => DateFormat.MMMd().format(modifiedAt);

  /// Converte um query [QuerySnapshot] em uma lista de [Note]
  static List<Note> fromQuery(QuerySnapshot snapshot) {
    return snapshot != null ? snapshot.toNotes() : [];
  }

  /// Atualiza esta Nota com outra.
  /// Se [updateTimestamp] for `true` - o que é o padrão -
  /// `modifiedAt` será atualizada para `DateTime.now()`,
  /// caso contrário também será copiada de [other]
  void update(Note other, {bool updateTimestamp = true}) {
    title = other.title;
    content = other.content;
    color = other.color;
    state = other.state;

    if (updateTimestamp || other.modifiedAt == null) {
      modifiedAt = DateTime.now();
    } else {
      modifiedAt = other.modifiedAt;
    }
    notifyListeners();
  }

  /// Atualize esta Nota com propriedades especificadas.
  /// Se [updateTimestamp] for `true` - o que é o padrão -
  /// `modifiedAt` será atualizada para `DateTime.now()`.
  Note updateWith({
    String title,
    String content,
    Color color,
    NoteState state,
    bool updateTimestamp = true,
  }) {
    if (title != null) this.title = title;
    if (content != null) this.content = content;
    if (color != null) this.color = color;
    if (state != null) this.state = state;
    if (updateTimestamp) modifiedAt = DateTime.now();
    notifyListeners();
    return this;
  }

  /// Faz uma cópia desta Nota
  /// Se [updateTimestamp] for `true` - o padrão é `false` -
  /// `createdAt` e `modifiedAt` serão atualizadas para `DateTime.now()`,
  /// caso contrário serão identicas às desta nota.
  Note copy({bool updateTimestamp = false}) => Note(
    id: id,
    createdAt: (updateTimestamp || createdAt == null) ? DateTime.now() : createdAt,
  )..update(this, updateTimestamp: updateTimestamp);

  /// Serializa esta nota em um objeto JSON
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'color': color?.value,
    'state': stateValue,
    'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    'modifiedAt': (modifiedAt ?? DateTime.now()).millisecondsSinceEpoch,
  };

}

/// Enum para o estado de uma Nota
enum NoteState {
  unspecified, // padrão
  pinned, // fixada
  archived, // arquivada
  deleted, // removida
  removedForever, // removida permanentemente
}

/// Adiciona propriedades e métodos a [NoteState]
extension NoteStateX on NoteState {
  bool operator <(NoteState other) => (this?.index ?? 0) < (other?.index ?? 0);
  bool operator <=(NoteState other) => (this?.index ?? 0) <= (other?.index ?? 0);

  /// Verifica se é permitido criar uma nova nota neste estado.
  bool get canCreate => this <= NoteState.pinned;

  /// Verifica se uma nota neste estado pode ser editada
  bool get canEdit => this < NoteState.deleted;

  /// Label do filtro atual
  String get filterName {
    switch (this) {
      case NoteState.archived:
        return 'Arquivo';
      case NoteState.deleted:
        return 'Lixeira';
      default:
        return '';
    }
  }

  /// Mensagem de transição de estado
  String get message {
    switch (this) {
      case NoteState.archived:
        return 'Nota arquivada';
      case NoteState.deleted:
        return 'Nota excluída';
      case NoteState.removedForever:
        return 'Nota excluída permanentemente';
      default:
        return '';
    }
  }

  /// Mensagem de sem resultados de acordo com o estado/filtro
  String get emptyResultMessage {
    switch (this) {
      case NoteState.archived:
        return 'Notas arquivadas aparecem aqui';
      case NoteState.deleted:
        return 'Notas excluídas aparecem aqui';
      default:
        return 'Notas criadas aparecem aqui';
    }
  }
}
