// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:codegen/helper/utils.dart';
import 'package:recase/recase.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  var location = Platform.script.toString();
  var isNewFlutter = location.contains(".snapshot");
  if (isNewFlutter) {
    var sp = Platform.script.toFilePath();
    var sd = sp.split(Platform.pathSeparator);
    sd.removeLast();
    var scriptDir = sd.join(Platform.pathSeparator);
    var packageConfigPath = [scriptDir, '..', '..', '..', 'package_config.json'].join(Platform.pathSeparator);
    // print(packageConfigPath);
    var jsonString = File(packageConfigPath).readAsStringSync();
    // print(jsonString);
    Map<String, dynamic> packages = jsonDecode(jsonString);
    var packageList = packages["packages"];
    String? codegenUri;
    for (var package in packageList) {
      if (package["name"] == "codegen") {
        codegenUri = package["rootUri"];
        break;
      }
    }
    if (codegenUri == null) {
      print("error uri");
      return;
    }
    if (codegenUri.contains("../../")) {
      codegenUri = codegenUri.replaceFirst("../", "");
      codegenUri = path.absolute(codegenUri, "");
    }
    if (codegenUri.contains("file:///")) {
      codegenUri = codegenUri.replaceFirst("file://", "");
      codegenUri = path.absolute(codegenUri, "");
    }
    location = codegenUri;
  }

  if (args.isEmpty) {
    printError("Please named new feature");
    return;
  }
  ReCase rc = ReCase(args.first);
  String appRootFolder = path.absolute("", "");

  var pubFile = File("$appRootFolder/pubspec.yaml");
  var doc = loadYaml(pubFile.readAsStringSync());
  String appName = doc['name'];

  String libPath = "$location/lib";
  String templatePath = "$libPath/template/feature/example";
  String repositoryPath = "$libPath/template/repository";
  String featureAppPath = "$appRootFolder/lib/feature/${rc.snakeCase}";
  String commonAppPath = "$appRootFolder/lib";
  String routerAppPath = "$commonAppPath/route";
  String repositoryAppPath = "$commonAppPath/repository";
  var list = await dirContents(Directory(templatePath));
  for (var element in list) {
    // CREATE DIRECTORY
    if (element.toString().contains("Directory")) {
      var newFolder = "$featureAppPath${element.path.replaceFirst(templatePath, "")}";
      if (!Directory(newFolder).existsSync()) {
        print("CREATE FOLDER => $newFolder");
        Directory(newFolder).createSync(recursive: true);
      }
    } else {
      String fileContent = await createFile(element.path, rc, appName);
      var newFile = "$featureAppPath${element.path.replaceFirst(templatePath, "").replaceAll("example", rc.snakeCase).replaceFirst(".stub", "")}";
      print("CREATE FILE => $newFile");
      File(newFile).writeAsStringSync(fileContent);

      // break;
    }
  }

  //CREATE REPOSITORY
  if (!Directory(repositoryAppPath).existsSync()) {
    print("CREATE FOLDER => $repositoryAppPath");
    Directory(repositoryAppPath).createSync(recursive: true);
  }

  String repositoryContent = await createFile("$repositoryPath/example_repository.dart", rc, appName);
  String repositoryFile = "$repositoryAppPath/${rc.snakeCase}_repository.dart";
  if (!Directory(repositoryAppPath).existsSync()) {
    print("CREATE FOLDER => $repositoryAppPath");
    Directory(repositoryAppPath).createSync(recursive: true);
  }
  print("Create File Repository $repositoryFile");
  File(repositoryFile).writeAsStringSync(repositoryContent);

  // APPEND ROUTE CONSTANT
  String routerAppendContent = "static const ${rc.camelCase} = '/${rc.snakeCase}';";
  String routerFile = "$routerAppPath/route.constant.dart";
  String routerFileContent = File(routerFile).readAsStringSync();
  String newFileRouterContent = routerFileContent.replaceAll("// PLEASE DON'T REMOVE THIS LINE", "$routerAppendContent\n  // PLEASE DON'T REMOVE THIS LINE");

  // APPEND ROUTE PAGES
  String routerGeneratorAppendContent = """
GetPage(
      name: RouteConstants.example,
      page: () => const ExampleScreen(),
      binding: ExampleBinding(),
    ),
  """;
  routerGeneratorAppendContent = routerGeneratorAppendContent.replaceAll("example", rc.camelCase).replaceAll("Example", rc.pascalCase);
  String routerGeneratorFile = "$routerAppPath/route.pages.dart";
  String routerGeneratorFileContent = File(routerGeneratorFile).readAsStringSync();

  // APPEND IMPORT ROUTE
  String routeImportArgs = "import 'package:$appName/feature/${rc.snakeCase}/binding/${rc.snakeCase}_binding.dart';";
  String routeImportPage = "import 'package:$appName/feature/${rc.snakeCase}/screen/${rc.snakeCase}_screen.dart';";
  String newFileRouterGeneratorContent =
      routerGeneratorFileContent.replaceAll("// PLEASE DON'T REMOVE THIS LINE", "$routerGeneratorAppendContent\n      // PLEASE DON'T REMOVE THIS LINE");
  newFileRouterGeneratorContent = newFileRouterGeneratorContent.replaceFirst(
      "// PLEASE DON'T REMOVE THIS IMPORT LINE", "$routeImportArgs\n$routeImportPage\n// PLEASE DON'T REMOVE THIS IMPORT LINE");
  File(routerFile).writeAsStringSync(newFileRouterContent);
  File(routerGeneratorFile).writeAsStringSync(newFileRouterGeneratorContent);
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: true);
  lister.listen((file) => files.add(file),
      // should also register onError
      onDone: () => completer.complete(files));
  return completer.future;
}

Future<String> createFile(String path, ReCase rc, String appName) async {
  String result = File(path).readAsStringSync();
  result = result.replaceAll("appName", appName);
  result = result.replaceAll("Example", rc.pascalCase);
  result = result.replaceAll("example", rc.snakeCase);
  result = result.replaceAll("EXAMPLE", rc.constantCase);
  return result;
}
