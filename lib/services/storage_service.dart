import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StorageService {
  Future<String> getDownloadPath(String fileName) async {
    final directory = await getExternalStorageDirectory();
    return '${directory?.path}/$fileName';
  }

  Future<void> saveBookToStorage(String fileName, List<int> data) async {
    final path = await getDownloadPath(fileName);
    final file = File(path);
    await file.writeAsBytes(data);
  }
}
