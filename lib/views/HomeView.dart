import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_keep/icons.dart' show AppIcons;
import 'package:flutter_keep/models.dart' show User, Note, NoteState, NoteStateX, NoteFilter;
import 'package:flutter_keep/services.dart' show notesCollection, CommandHandler;
import 'package:flutter_keep/widgets.dart' show AppDrawer, NotesGrid, NotesList;
import 'package:flutter_keep/styles.dart';
import 'package:flutter_keep/helpers.dart';

/// Tela inicial
class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with CommandHandler {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// View das Notas: grid ou lista - grid padrão
  bool _gridView = true;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NoteFilter(),
        ),
        Consumer<NoteFilter>(
          builder: (context, filter, child) => StreamProvider.value(
            value: _createNoteStream(context, filter),
            child: child,
          ),
        ),
      ],
      child: Consumer2<NoteFilter, List<Note>>(
        builder: (context, filter, notes, child) {
          final hasNotes = notes?.isNotEmpty == true;
          final canCreate = filter.noteState.canCreate;

          return Scaffold(
            key: _scaffoldKey,
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 720),
                child: CustomScrollView(
                  slivers: <Widget>[
                    _appBar(context, filter, child),

                    if (hasNotes) const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                    ..._buildNotesView(context, filter, notes),

                    if (hasNotes) SliverToBoxAdapter(
                      child: SizedBox(height: (canCreate ? kBottomBarSize : 10.0) + 10.0),
                    ),
                  ],
                ),
              ),
            ),
            drawer: AppDrawer(),
            floatingActionButton: canCreate ? _fab(context) : null,
            bottomNavigationBar: canCreate ? _bottomActions() : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            extendBody: true,
          );
        },
      ),
    ),
  );

  /// Buscar e listar as Notas
  Stream<List<Note>> _createNoteStream(BuildContext context, NoteFilter filter) {
    final user = Provider.of<User>(context)?.data;
    final collection = notesCollection(user?.uid);

    final query = filter.noteState == NoteState.unspecified
        ? collection
    // notas "normais" e notas fixadas
        .where('state', whereIn: [NoteState.unspecified.index, NoteState.pinned.index])
    // notas fixadas primeiro
        .orderBy('state', descending: true)
        : collection
        .where('state', isEqualTo: filter.noteState.index);

    return query
        .snapshots()
        .handleError((e) => debugPrint('query notes failed: $e'))
        .map((snapshot) => Note.fromQuery(snapshot));
  }

  Widget _appBar(BuildContext context, NoteFilter filter, Widget bottom) {
    return filter.noteState < NoteState.archived
        ? SliverAppBar(
      floating: true,
      snap: true,
      title: _topActions(context),
      automaticallyImplyLeading: false,
      centerTitle: true,
      titleSpacing: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
    )
        : SliverAppBar(
      floating: true,
      snap: true,
      title: Text(filter.noteState.filterName),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      automaticallyImplyLeading: false,
    );
  }

  Widget _topActions(BuildContext context) => Container(
    constraints: const BoxConstraints(
      maxWidth: 720,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 7 : 5),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 20),
            InkWell(
              child: const Icon(Icons.menu),
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text('Minhas notas',
                softWrap: false,
                style: TextStyle(
                  color: kHintTextColorLight,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              child: Icon(_gridView ? AppIcons.view_list : AppIcons.view_grid),
              onTap: () => setState(() {
                _gridView = !_gridView;
              }),
            ),
            const SizedBox(width: 18),
            _buildAvatar(context),
            const SizedBox(width: 10),
          ],
        ),
      ),
    ),
  );

  Widget _buildAvatar(BuildContext context) {
    final url = Provider.of<User>(context)?.data?.photoUrl;
    return CircleAvatar(
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null ? const Icon(Icons.face) : null,
      radius: isNotAndroid ? 19 : 17,
    );
  }

  Widget _buildBlankView(NoteState filteredState) => SliverFillRemaining(
    hasScrollBody: false,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Expanded(flex: 1, child: SizedBox()),
        Icon(AppIcons.thumbtack,
          size: 80,
          color: kAccentColorLight.shade800,
        ),
        Expanded(
          flex: 2,
          child: Text(filteredState.emptyResultMessage,
            style: TextStyle(
              color: kHintTextColorLight,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _buildNotesView(BuildContext context, NoteFilter filter, List<Note> notes) {
    if (notes?.isNotEmpty != true) {
      return [_buildBlankView(filter.noteState)];
    }

    final asGrid = filter.noteState == NoteState.deleted || _gridView;
    final factory = asGrid ? NotesGrid.create : NotesList.create;
    final showPinned = filter.noteState == NoteState.unspecified;

    if (!showPinned) {
      return [
        factory(notes: notes, onTap: _onNoteTap),
      ];
    }

    final partition = _partitionNotes(notes);
    final hasPinned = partition.item1.isNotEmpty;
    final hasUnpinned = partition.item2.isNotEmpty;

    final _buildLabel = (String label, [double top = 26]) => SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 26, bottom: 25, top: top),
        child: Text(label, style: const TextStyle(
            color: kHintTextColorLight,
            fontWeight: FontWeights.medium,
            fontSize: 12),
        ),
      ),
    );

    return [
      if (hasPinned) _buildLabel('FIXADOS', 0),
      if (hasPinned) factory(notes: partition.item1, onTap: _onNoteTap),
      if (hasPinned && hasUnpinned) _buildLabel('NOTAS'),
      factory(notes: partition.item2, onTap: _onNoteTap),
    ];
  }

  void _onNoteTap(Note note) async {
    final command = await Navigator.pushNamed(context, '/note', arguments: { 'note': note });
    processNoteCommand(_scaffoldKey.currentState, command);
    setState((){ });
  }

  Tuple2<List<Note>, List<Note>> _partitionNotes(List<Note> notes) {
    if (notes?.isNotEmpty != true) {
      return Tuple2([], []);
    }

    final indexUnpinned = notes?.indexWhere((n) => !n.pinned);

    return indexUnpinned > -1
        ? Tuple2(notes.sublist(0, indexUnpinned), notes.sublist(indexUnpinned))
        : Tuple2(notes, []);
  }

  Widget _fab(BuildContext context) => FloatingActionButton(
    backgroundColor: Theme.of(context).accentColor,
    child: const Icon(Icons.add),
    onPressed: () async {
      final command = await Navigator.pushNamed(context, '/note');
      processNoteCommand(_scaffoldKey.currentState, command);
      setState((){ });
    },
  );

  Widget _bottomActions() => BottomAppBar(
    shape: const CircularNotchedRectangle(),
    child: Container(
      height: kBottomBarSize,
      padding: const EdgeInsets.symmetric(horizontal: 17),
    ),
  );
}

const _10_min_millis = 600;
