import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DriveService {
  late final drive.DriveApi _api;
  DriveService(http.Client client) : _api = drive.DriveApi(client);

  Future<String?> findRemoteFileId(String name) async {
    final res = await _api.files.list(q: "name='$name' and trashed=false");
    if (res.files == null || res.files!.isEmpty) return null;
    return res.files!.first.id;
  }

  Future<void> uploadFile(String? id, String localPath) async {
    final file = File(localPath);
    final media = drive.Media(file.openRead(), await file.length());
    final metadata = drive.File()..name = basename(localPath);
    if (id == null) {
      await _api.files.create(metadata, uploadMedia: media);
    } else {
      await _api.files.update(metadata, id, uploadMedia: media);
    }
  }

  Future<void> downloadFile(String id, String destPath) async {
    final resp = await _api.files.get(
      id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final out = File(destPath).openWrite();
    await resp.stream.pipe(out);
    await out.flush();
  }
}
