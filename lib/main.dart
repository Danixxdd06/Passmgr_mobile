import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';  // para getApplicationDocumentsDirectory

import 'models/config_model.dart';
import 'services/config_service.dart';
import 'services/crypto_service.dart';
import 'services/db_service.dart';
import 'services/auth_service.dart';
import 'services/drive_service.dart';
import 'ui/setup_master_screen.dart';
import 'ui/login_screen.dart';
import 'ui/home_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Carga config local
  final config = await ConfigService.loadConfig();
  // Si no hay contraseña maestra, arrancamos en modo setup
  if (config.masterPassword.isEmpty) {
    runApp(MaterialApp(
      title: 'PassMgr Setup',
      home: SetupMasterScreen(onMasterSaved: (pwd, theme) async {
        config.masterPassword = pwd;
        config.theme = theme;
        await ConfigService.saveConfig(config);
        // Reiniciar toda la app para continuar el flujo normal
        exit(0);
      }),
    ));
    return;
  }

  // 2) Inicializa el cifrador
  final cryptoService = CryptoService();
  await cryptoService.init(config.masterPassword);


  // 3) Abre la base de datos cifrada
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = join(appDir.path, 'passmgr.db');
  await DBService.openDb(dbPath, config.masterPassword);

  // 4) Autenticación Google + Drive
  final authService = AuthService();
  await authService.signIn(); // lanza pantalla OAuth de Google
  if (!authService.isSignedIn) {
    // Si canceló, cierra la app
    exit(0);
  }
  final driveService = DriveService(authService.client!);

  // 5) Primera sincronización
  final remoteId = await driveService.findRemoteFileId('passmgr.db');
  if (remoteId != null) {
    // Descarga y reemplaza la DB local
    await driveService.downloadFile(remoteId, dbPath);
  } else {
    // Sube la DB local por primera vez
    await driveService.uploadFile(null, dbPath);
  }

  // 6) Arranca la app normal
  runApp(MyApp(config: config, driveService: driveService, authService: authService));
}

class MyApp extends StatelessWidget {
  final ConfigModel config;
  final DriveService driveService;
  final AuthService authService;

  const MyApp({
    Key? key,
    required this.config,
    required this.driveService,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassMgr',
      theme: config.theme == 'dark' ? ThemeData.dark() : ThemeData.light(),
      home: LoginScreen(
        correctMaster: config.masterPassword,
        onLoginSuccess: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => HomeScreen(
              driveService: driveService,
              authService: authService,
              theme: config.theme,
            ),
          ));
        },
      ),
    );
  }
}
