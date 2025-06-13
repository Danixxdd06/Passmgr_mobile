// lib/services/auth_service.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Cliente HTTP que añade automáticamente los headers de OAuth2.
class AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

/// Servicio de autenticación con Google Sign-In y proveedor de un cliente HTTP autenticado.
class AuthService {
  // Pedimos permiso sólo para gestionar archivos en Drive
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  GoogleSignInAccount? _currentUser;
  AuthenticatedClient? _client;

  /// Stream para escuchar cambios de usuario (login/logout).
  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  /// Inicia el flujo de Google Sign-In.
  /// Devuelve la cuenta o null si el usuario canceló.
  Future<GoogleSignInAccount?> signIn() async {
    _currentUser = await _googleSignIn.signIn();
    if (_currentUser != null) {
      final auth = await _currentUser!.authentication;
      final headers = {'Authorization': 'Bearer ${auth.accessToken}'};
      _client = AuthenticatedClient(headers);
    }
    return _currentUser;
  }

  /// Cierra sesión y limpia el cliente.
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    _currentUser = null;
    _client = null;
  }

  /// Indica si hay un usuario autenticado.
  bool get isSignedIn => _currentUser != null;

  /// Devuelve el cliente HTTP ya autenticado (o null si no hay sesión).
  http.Client? get client => _client;
}
