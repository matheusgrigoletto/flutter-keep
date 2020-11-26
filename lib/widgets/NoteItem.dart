import 'package:flutter/material.dart';
import 'package:flutter_keep/models/Note.dart' show Note;
import 'package:flutter_keep/styles.dart';

/// Preview da [Note] na listagem
class NoteItem extends StatelessWidget {
  const NoteItem({
    Key key,
    this.note,
  }) : super(key: key);

  final Note note;

  @override
  Widget build(BuildContext context) => Hero(
    tag: 'NoteItem${note.id}',
    child: DefaultTextStyle(
      style: kNoteTextLight,
      child: Container(
        decoration: BoxDecoration(
          color: note.color,
          borderRadius: BorderRadius.all(Radius.circular(6)),
          border: note.color.value == 0xFFFFFFFF ? Border.all(color: kBorderColorLight) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (note.title?.isNotEmpty == true) Text(note.title,
              style: kCardTitleLight,
              maxLines: 1,
            ),
            if (note.title?.isNotEmpty == true) const SizedBox(height: 14),
            Flexible(
              flex: 1,
              child: Text(note.content ?? ''),
            ),
          ],
        ),
      ),
    ),
  );
}
