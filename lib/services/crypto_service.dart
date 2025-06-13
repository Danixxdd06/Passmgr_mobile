// lib/services/crypto_service.dart
// lib/services/crypto_service.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  static const _saltFile = 'salt.bin';
  final Pbkdf2 _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 390000,
    bits: 256,
  );
  final AesGcm _aes = AesGcm.with256bits();
  late final SecretKey _secretKey;

  Future<void> init(String masterPwd) async {
    final salt = await _getSalt();
    // PBKDF2 no recibe "nonce", recibe salt explícito
    _secretKey = await _kdf.deriveKey(
      secretKey: SecretKey(masterPwd.codeUnits),
      nonce: salt,        // aquí va la salt, no un newNonce()
    );
  }

  Future<Uint8List> encrypt(String plain) async {
    final nonce = _aes.newNonce();  // este metodo si existe en AesGcm
    final secretBox = await _aes.encrypt(
      plain.codeUnits,
      secretKey: _secretKey,
      nonce: nonce,
    );
    // concatenamos nonce + ciphertext + mac automáticamente incluido
    return Uint8List.fromList(nonce + secretBox.cipherText + secretBox.mac.bytes);
  }

  Future<String> decrypt(Uint8List blob) async {
    // nonce: primeros 12 bytes, mac: últimos 16
    final nonce = blob.sublist(0, 12);
    final macBytes = blob.sublist(blob.length - 16);
    final cipherText = blob.sublist(12, blob.length - 16);
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));
    final clear = await _aes.decrypt(
      secretBox,
      secretKey: _secretKey,
    );
    return String.fromCharCodes(clear);
  }

  Future<Uint8List> _getSalt() async {
    final f = File(_saltFile);
    if (await f.exists()) return f.readAsBytes();
    final rnd = Random.secure();
    final salt = Uint8List.fromList(List.generate(16, (_) => rnd.nextInt(256)));
    await f.writeAsBytes(salt);
    return salt;
  }
}
