import 'package:ansicolor/ansicolor.dart';

void debugPrint(String debug) {
  AnsiPen pen = AnsiPen()..red();
  print(pen('[DEBUG]: $debug'));
}

void printError(String error) {
  AnsiPen pen = AnsiPen()..red();
  print(pen('[ERROR]: $error'));
}

void printWarning(String error) {
  AnsiPen pen = AnsiPen()..yellow();
  print(pen('[WARNING]: $error'));
}

String stringToType(String type) {
  switch (type) {
    case "int":
      return "int";
    case "string":
      return "String";
    case "bool":
    case "boolean":
      return "bool";
    case "double":
    case "decimal":
    case "float":
      return "double";
    case "function":
      return "Function()";
    case "map":
      return "Map<String,dynamic>";
    default:
      return type;
  }
}