import 'package:flutter/material.dart';
import '../services/drive_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final DriveService driveService;
  final AuthService authService;
  final String theme;
  const HomeScreen({required this.driveService, required this.authService, required this.theme, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PassMgr'),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              // aquí puedes llamar driveService.uploadFile(...)
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Sync pulsado')));
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await authService.signOut();
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
      body: Center(child: Text('Aquí irá tu lista de contraseñas')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () { /* abrir edición */ },
      ),
    );
  }
}
