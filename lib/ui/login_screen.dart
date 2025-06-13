import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final String correctMaster;
  final VoidCallback onLoginSuccess;
  const LoginScreen({required this.correctMaster, required this.onLoginSuccess, Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _ctrl,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Maestra'),
            onSubmitted: (_) => _try(),
          ),
          ElevatedButton(onPressed: _try, child: Text('Entrar')),
        ]),
      ),
    );
  }

  void _try() {
    if (_ctrl.text == widget.correctMaster) {
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incorrecto')));
    }
  }
}
