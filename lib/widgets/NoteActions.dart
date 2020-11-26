import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_keep/styles.dart';
import 'package:flutter_keep/icons.dart';
import 'package:flutter_keep/models.dart';
import 'package:flutter_keep/services.dart' show NoteStateUpdateCommand;

/// Ações para uma nota [Note], dentro de um [BottomSheet].
class NoteActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final note = Provider.of<Note>(context);
    final uid = Provider.of<User>(context)?.data?.uid;
    final state = note?.state;
    final id = note?.id;
    final textStyle = TextStyle(
      color: kHintTextColorLight,
      fontSize: 16,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (id != null && state < NoteState.archived) ListTile(
          leading: const Icon(AppIcons.archive_outlined),
          title: Text('Arquivar', style: textStyle),
          onTap: () => Navigator.pop(context, NoteStateUpdateCommand(
            id: id,
            uid: uid,
            from: state,
            to: NoteState.archived,
            dismiss: true,
          )),
        ),
        if (state == NoteState.archived) ListTile(
          leading: const Icon(AppIcons.unarchive_outlined),
          title: Text('Desarquivar', style: textStyle),
          onTap: () => Navigator.pop(context, NoteStateUpdateCommand(
            id: id,
            uid: uid,
            from: state,
            to: NoteState.unspecified,
          )),
        ),
        if (id != null && state != NoteState.deleted) ListTile(
          leading: const Icon(AppIcons.delete_outline),
          title: Text('Excluir', style: textStyle),
          onTap: () => Navigator.pop(context, NoteStateUpdateCommand(
            id: id,
            uid: uid,
            from: state,
            to: NoteState.deleted,
            dismiss: true,
          )),
        ),
        if (state == NoteState.deleted) ListTile(
          leading: const Icon(AppIcons.restore),
          title: Text('Restaurar', style: textStyle),
          onTap: () => Navigator.pop(context, NoteStateUpdateCommand(
            id: id,
            uid: uid,
            from: state,
            to: NoteState.unspecified,
          )),
        ),
        if (state == NoteState.deleted) ListTile(
          leading: const Icon(AppIcons.delete_forever),
          title: Text('Excluir permanentemente', style: textStyle),
          onTap: () => Navigator.pop(context, NoteStateUpdateCommand(
            id: id,
            uid: uid,
            from: state,
            to: NoteState.removedForever,
            dismiss: true,
          )),
        ),
      ],
    );
  }
}
