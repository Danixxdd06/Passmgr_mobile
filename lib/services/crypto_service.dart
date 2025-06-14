// lib/services/crypto_service.dart

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CryptoService {
  static const _saltFileName = 'salt.bin';

  final Pbkdf2 _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 390000,
    bits: 256,
  );

  final AesGcm _aes = AesGcm.with256bits();

  late final SecretKey _secretKey;

  /// Inicializa la clave derivada a partir de la contraseña maestra
  Future<void> init(String masterPwd) async {
    final salt = await _getSalt();
    _secretKey = await _kdf.deriveKey(
      secretKey: SecretKey(masterPwd.codeUnits),
      nonce: salt,
    );
  }

  /// Cifra un texto plano en Uint8List = nonce | ciphertext | mac
  Future<Uint8List> encrypt(String plain) async {
    final nonce = _aes.newNonce();
    final secretBox = await _aes.encrypt(
      plain.codeUnits,
      secretKey: _secretKey,
      nonce: nonce,
    );
    return Uint8List.fromList(nonce + secretBox.cipherText + secretBox.mac.bytes);
  }

  /// Descifra el blob generado por [encrypt]
  Future<String> decrypt(Uint8List blob) async {
    final nonce = blob.sublist(0, 12);
    final macBytes = blob.sublist(blob.length - 16);
    final cipherText = blob.sublist(12, blob.length - 16);
    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );
    final clear = await _aes.decrypt(
      secretBox,
      secretKey: _secretKey,
    );
    return String.fromCharCodes(clear);
  }

  //////////////////////////////////////////////////////////////////////////////
  //     SALT HANDLING
  //
  //  Guardamos el salt en un fichero salt.bin dentro del directorio
  //  de documentos de la app, que sí es escribible en Android/iOS.
  //////////////////////////////////////////////////////////////////////////////

  /// Ruta completa al fichero salt.bin en app data
  Future<String> _saltFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return join(dir.path, _saltFileName);
  }

  /// Lee o genera el salt (16 bytes) y lo persiste en app data
  Future<Uint8List> _getSalt() async {
    final path = await _saltFilePath();
    final file = File(path);

    if (await file.exists()) {
      return await file.readAsBytes();
    }

    // Genera un nuevo salt aleatorio
    final rnd = Random.secure();
    final salt = Uint8List.fromList(
      List<int>.generate(16, (_) => rnd.nextInt(256)),
    );

    // Escribe el salt en disco
    await file.writeAsBytes(salt, flush: true);
    return salt;
  }
}
