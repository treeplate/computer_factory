class File {
  File(String arg);
  void writeAsStringSync(String arg, {required FileMode mode}) {}
}

enum FileMode { append, write }
