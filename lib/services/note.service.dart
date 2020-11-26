import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection_ext/iterables.dart';
import 'package:flutter_keep/styles.dart';
import 'package:flutter_keep/models.dart' show Note, NoteState;

/// Retorna a [CollectionReference] de notas do usuário [uid].
CollectionReference notesCollection(String uid) => Firestore.instance.collection('notes-$uid');

/// Retorna a referência à nota [id] do usuário [uid].
DocumentReference noteDocument(String id, String uid) => notesCollection(uid).document(id);

/// Atualiza a nota [id] do usuário [uid] com os dados [data].
Future<void> updateNote(Map<String, dynamic> data, String id, String uid) =>
    noteDocument(id, uid).updateData(data);

/// Remove a nota [id] do usuário [uid].
Future<void> deleteNote(String id, String uid) =>
    noteDocument(id, uid).delete();

/// Atualiza a nota para o estado [state]
Future<void> updateNoteState(NoteState state, String id, String uid) =>
    updateNote({'state': state?.index ?? 0}, id, uid);

/// Uma ação que pode ser desfeita para uma [Note]
@immutable
abstract class NoteCommand {
  final String id;
  final String uid;

  /// Se este comando deve dispensar a tela atual.
  final bool dismiss;

  /// Define uma ação que pode ser desfeita para uma nota, fornece a nota [id]
  /// e o usuário atual [uid].
  const NoteCommand({
    @required this.id,
    @required this.uid,
    this.dismiss = false,
  });

  /// Retorna `true` se este comando puder ser desfeito.
  bool get isUndoable => true;

  /// Retorna mensagem sobre o resultado da ação.
  String get message => '';

  /// Executa este comando.
  Future<void> execute();

  /// Desfaz o comando.
  Future<void> revert();
}

/// [NoteCommand] para atualizar o estado de uma [Note].
class NoteStateUpdateCommand extends NoteCommand {
  final NoteState from;
  final NoteState to;

  /// Cria um [NoteCommand] para atualizar o estado de uma nota do estado
  /// atual [from] para [to]
  NoteStateUpdateCommand({
    @required String id,
    @required String uid,
    @required this.from,
    @required this.to,
    bool dismiss = false,
  }) : super(id: id, uid: uid, dismiss: dismiss);

  @override
  String get message {
    switch (to) {
      case NoteState.deleted:
        return 'Nota excluída';
      case NoteState.removedForever:
        return 'Excluída permanentemente';
      case NoteState.archived:
        return 'Nota arquivada';
      case NoteState.pinned:
        return from == NoteState.archived
            ? 'Nota fixada e desarquivada'
            : '';
      default:
        switch (from) {
          case NoteState.archived:
            return 'Note desarquivada';
          case NoteState.deleted:
            return 'Note restaurada';
          default:
            return '';
        }
    }
  }

  @override
  Future<void> execute() => updateNoteState(to, id, uid);

  @override
  Future<void> revert() => updateNoteState(from, id, uid);
}

/// Mixin auxilia na execução de um [NoteCommand].
mixin CommandHandler<T extends StatefulWidget> on State<T> {
  /// Executa o comando [command].
  Future<void> processNoteCommand(ScaffoldState scaffoldState, NoteCommand command) async {
    if (command == null) {
      return;
    }

    await command.execute();

    final msg = command.message;

    if (mounted && msg?.isNotEmpty == true && command.isUndoable) {
      scaffoldState?.showSnackBar(SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => command.revert(),
        ),
      ));
    }
  }
}

/// Extender [QuerySnapshot].
extension NoteQuery on QuerySnapshot {
  /// Transforma o resultado da consulta em uma lista de notas.
  List<Note> toNotes() => documents
      .map((d) => d.toNote())
      .nonNull
      .asList();
}

/// Extender [DocumentSnapshot].
extension NoteDocument on DocumentSnapshot {
  /// Transforma o resultado da consulta em uma nota [Note]
  Note toNote() {
    if (exists) {
      return Note(
        id: documentID,
        title: data['title'],
        content: data['content'],
        color: _parseColor(data['color']),
        state: NoteState.values[data['state'] ?? 0],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
        modifiedAt: DateTime.fromMillisecondsSinceEpoch(data['modifiedAt'] ?? 0),
      );
    }
    return null;
  }

  Color _parseColor(num colorInt) => Color(colorInt ?? kNoteColors.first.value);
}

/// Adicionar métodos relacionados ao FireStore ao model [Note].
extension NoteStore on Note {
  /// Salvar no FireStore
  /// Se é uma nova nota, será criada automaticamente
  Future<dynamic> saveToFireStore(String uid) async {
    final col = notesCollection(uid);
    return id == null
        ? col.add(toJson())
        : col.document(id).updateData(toJson());
  }

  /// Atualiza o estado da nota para o estado [state].
  Future<void> updateState(NoteState state, String uid) async {
    /// remover pra sempre
    if (state == NoteState.removedForever) {
      return deleteNote(id, uid);
    }

    /// nova nota
    if (id == null) {
      return updateWith(state: state);
    }

    return updateNoteState(state, id, uid);
  }
}