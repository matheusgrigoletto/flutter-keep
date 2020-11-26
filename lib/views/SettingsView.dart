import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keep/styles.dart';

/// Tela de configurações
class SettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.copyWith(
        caption: Theme.of(context).textTheme.caption.copyWith(
          color: Colors.blueAccent.shade400,
          fontWeight: FontWeights.medium,
        ),
      ),
    ),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Configurações'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints.tightFor(width: 720),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildCaption(context, 'CONTA'),
                  ListTile(
                    title: Text('Sign out'),
                    onTap: () => _signOut(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildCaption(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(title, style: Theme.of(context).textTheme.caption),
  );

  void _signOut(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Tem certeza de que deseja sair da conta atual?'),
        actions: <Widget>[
          FlatButton(
            child: const Text('Não'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: const Text('Sim'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (yes) {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    }
  }
}
