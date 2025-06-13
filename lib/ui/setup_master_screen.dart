import 'package:flutter/material.dart';

class SetupMasterScreen extends StatefulWidget {
  final Future<void> Function(String pwd, String theme) onMasterSaved;
  const SetupMasterScreen({required this.onMasterSaved, Key? key}) : super(key: key);

  @override
  State<SetupMasterScreen> createState() => _SetupMasterScreenState();
}

class _SetupMasterScreenState extends State<SetupMasterScreen> {
  final _ctrl = TextEditingController();
  String _theme = 'dark';
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar contraseña maestra')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _ctrl, obscureText: true, decoration: InputDecoration(labelText: 'Maestra')),
          DropdownButton<String>(
            value: _theme,
            items: ['dark', 'light'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _theme = v!),
          ),
          ElevatedButton(
            onPressed: () => widget.onMasterSaved(_ctrl.text, _theme),
            child: Text('Guardar'),
          ),
        ]),
      ),
    );
  }
}
