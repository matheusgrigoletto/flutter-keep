import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection_ext/iterables.dart';

import 'package:flutter_keep/styles.dart';
import 'package:flutter_keep/models.dart' show Note;

/// Seletor de cor de fundo da nota
class LinearColorPicker extends StatelessWidget {

  /// Retorna a cor atual, fallback para a cor default
  Color _currColor(Note note) => note?.color ?? kDefaultNoteColor;

  @override
  Widget build(BuildContext context) {
    Note note = Provider.of<Note>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kNoteColors.flatMapIndexed((i, color) => [
          if (i == 0) const SizedBox(width: 17),
          InkWell(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: kColorPickerBorderColor),
              ),
              child: color == _currColor(note)
                  ? const Icon(Icons.check, color: kColorPickerBorderColor)
                  : null,
            ),
            onTap: () {
              if (color != _currColor(note)) {
                note.updateWith(color: color);
              }
            },
          ),
          SizedBox(width: i == kNoteColors.length - 1 ? 17 : 20),
        ]).asList(),
      ),
    );
  }
}
