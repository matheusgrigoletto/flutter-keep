import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_keep/icons.dart';
import 'package:flutter_keep/styles.dart';
import 'package:flutter_keep/helpers.dart';
import 'package:flutter_keep/models.dart';
import 'DrawerFilterItem.dart';

/// Menu lateral
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<NoteFilter>(
    builder: (context, filter, _) => Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _appDrawerHeader(context),
          if (isNotIOS) const SizedBox(height: 25),
          DrawerItem(
            icon: AppIcons.thumbtack,
            title: 'Notas',
            isChecked: filter.noteState == NoteState.unspecified,
            onTap: () {
              filter.noteState = NoteState.unspecified;
              Navigator.pop(context);
            },
          ),
          const Divider(),
          DrawerItem(
            icon: AppIcons.archive_outlined,
            title: 'Arquivo',
            isChecked: filter.noteState == NoteState.archived,
            onTap: () {
              filter.noteState = NoteState.archived;
              Navigator.pop(context);
            },
          ),
          DrawerItem(
            icon: AppIcons.delete_outline,
            title: 'Lixeira',
            isChecked: filter.noteState == NoteState.deleted,
            onTap: () {
              filter.noteState = NoteState.deleted;
              Navigator.pop(context);
            },
          ),
          const Divider(),
          DrawerItem(
            icon: AppIcons.settings_outlined,
            title: 'Configurações',
            onTap: () {
              Navigator.popAndPushNamed(context, '/settings');
            },
          ),
          DrawerItem(
            icon: AppIcons.about,
            title: 'Sobre',
            onTap: () => launch('https://github.com/matheusgrigoletto/flutter-keep'),
          ),
        ],
      ),
    ),
  );

  /// Cabeçalho do menu
  Widget _appDrawerHeader(BuildContext context) => SafeArea(
    child: Container(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            color: kAccentColorLight,
            fontSize: 26,
            fontWeight: FontWeights.light,
            fontStyle: FontStyle.italic,
            letterSpacing: -2.5,
          ),
          children: [
            const TextSpan(
              text: 'Flutter',
              style: TextStyle(
                color: kHintTextColorLight,
                fontWeight: FontWeights.medium,
                fontStyle: FontStyle.italic,
                letterSpacing: -2.5,
              ),
            ),
            const TextSpan(text: 'Keep'),
          ],
        ),
      ),
    ),
  );
}
