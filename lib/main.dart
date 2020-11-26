import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:provider/provider.dart';
import 'styles.dart';
import 'models.dart' show User;
import 'views.dart';

void main() {
  initializeDateFormatting("pt_BR", null).then((_) => runApp(FlutterKeepApp()));
}

class FlutterKeepApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamProvider.value(
    value: FirebaseAuth.instance.onAuthStateChanged.map((user) =>
        User.create(user)),
    initialData: User.initial,
    child: Consumer<User>(
      builder: (context, user, _) => MaterialApp(
        title: 'FlutterKeep',
        theme: Theme.of(context).copyWith(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          accentColor: kAccentColorLight,
          appBarTheme: AppBarTheme.of(context).copyWith(
            elevation: 0,
            brightness: Brightness.light,
            iconTheme: IconThemeData(
              color: kIconTintLight,
            ),
          ),
          scaffoldBackgroundColor: Colors.white,
          bottomAppBarColor: kBottomAppBarColorLight,
          primaryTextTheme: Theme.of(context).primaryTextTheme.copyWith(
            headline6: const TextStyle(
              color: kIconTintLight,
            ),
          ),
        ),
        home: user.isInitialValue
            ? Scaffold(body: const SizedBox())
            : user.data != null ? HomeView() : LoginView(),
        routes: {
          '/settings': (_) => SettingsView(),
        },
        onGenerateRoute: _generateRoute,
      ),
    ),
  );

  /// Callback usado para gerar as rotas dinâmicas
  Route _generateRoute(RouteSettings settings) {
    try {
      return _doGenerateRoute(settings);
    } catch (e, s) {
      debugPrint("Falha ao gerar rota dinâmica ===> $settings: $e $s");
      return null;
    }
  }

  /// Geras rotas nomeadas para as notas
  Route _doGenerateRoute(RouteSettings settings) {
    if (settings.name?.isNotEmpty != true) {
      return null;
    }

    final uri = Uri.parse(settings.name);
    final path = uri.path ?? '';

    switch (path) {
      case '/note': {
        final note = (settings.arguments as Map ?? {})['note'];
        return _buildRoute(settings, (_) => NoteEditorView(note: note));
      }
      default:
        return null;
    }
  }

  /// Cria um [Route] a partir de [settings] e [builder]
  Route _buildRoute(RouteSettings settings, WidgetBuilder builder) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: builder,
      );
}