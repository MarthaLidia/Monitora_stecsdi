/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-02-15
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.utils;

class UtilsReadWriteFile {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> localFile(String name) async {
    final path = await _localPath;
    return File('$path/$name.json');
  }

  static void writeLocalFile(String data, String name) async {
    final file = await localFile(name);
    file.writeAsString(data);
  }

  static Future<List<dynamic>> readLocalFile(String name) async {
    final file = await localFile(name);
    return jsonDecode(await file.readAsString());
  }
}
