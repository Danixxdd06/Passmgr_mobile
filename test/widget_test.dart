// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passmgr_mobile/main.dart';  // ajústalo al nombre de tu paquete

void main() {
  testWidgets('La app arranca y muestra SetupMasterScreen si no hay maestra', (WidgetTester tester) async {
    // Arranca la app
    await tester.pumpWidget(MyAppLauncher());
    await tester.pumpAndSettle();

    // Si tu flujo inicial detecta que no hay masterPwd, lanza SetupMasterScreen:
    expect(find.text('Configurar contraseña maestra'), findsOneWidget);
  });
}
