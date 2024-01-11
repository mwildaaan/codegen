// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:codegen/model/my_fonts.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'generate.dart' as generate;

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

  String appRootFolder = path.absolute("", "");
  var pubFile = File("$appRootFolder/pubspec.yaml");
  var doc = loadYaml(pubFile.readAsStringSync(), recover: true);
  String appName = doc['name'];
  String libPath = "$location/lib";
  String servicePath = "$libPath/template/services";
  String constantPath = "$libPath/template/constants";
  String corePath = "$libPath/template/core";
  String othersPath = "$libPath/template";
  String serviceAppPath = "$appRootFolder/lib/services";
  String constantAppPath = "$appRootFolder/lib/constants";
  String coreAppPath = "$appRootFolder/lib/core";
  String libAppPath = "$appRootFolder/lib";
  String routerAppPath = "$libAppPath/route";
  var pubSpec = jsonDecode(jsonEncode(doc));
  for (var e in packages) {
    pubSpec["dependencies"][e.name] = e.version;
  }

  // CREATE PUBSPEC ASSETS
  if (!pubSpec["flutter"].containsKey("assets")) {
    pubSpec["flutter"]["assets"] = [];
  }
  if (!pubSpec["flutter"]["assets"].contains("assets/images/")) {
    pubSpec["flutter"]["assets"].add("assets/images/");
  }
  if (!pubSpec["flutter"]["assets"].contains("assets/images/icons/")) {
    pubSpec["flutter"]["assets"].add("assets/images/icons/");
  }

  // CREATE DIR FONTS
  if (!Directory("$appRootFolder/fonts").existsSync()) {
    print("CREATE FOLDER => $appRootFolder/fonts");
    Directory("$appRootFolder/fonts").createSync(recursive: true);
  }

  // CREATE DIR ASSETS
  if (!Directory("$appRootFolder/assets/images").existsSync()) {
    print("CREATE FOLDER => $appRootFolder/assets/images");
    Directory("$appRootFolder/assets/images").createSync(recursive: true);
  }
  if (!Directory("$appRootFolder/assets/images/icons").existsSync()) {
    print("CREATE FOLDER => $appRootFolder/assets/images/icons");
    Directory("$appRootFolder/assets/images/icons").createSync(recursive: true);
  }

  pubFile.writeAsStringSync(json2yaml(pubSpec));

  print("INSTALL DEPENDENCY ....");
  Process.run("flutter", ["pub", "get"]);

  // ADD SERVICE
  String serviceContent = File("$servicePath/api_client.dart.stub").readAsStringSync();
  String serviceFile = "$serviceAppPath/api_client.dart";
  if (!Directory(serviceAppPath).existsSync()) {
    print("CREATE FOLDER => $serviceAppPath");
    Directory(serviceAppPath).createSync(recursive: true);
  }
  print("Create File API_CLIENT $serviceFile");
  File(serviceFile).writeAsStringSync(serviceContent.replaceAll("appName", appName));

  // ADD CANONCIAL_PATH
  String canocialContent = File("$constantPath/canoncial_path.dart").readAsStringSync();
  String canoncialFile = "$constantAppPath/canoncial_path.dart";
  if (!Directory(constantAppPath).existsSync()) {
    print("CREATE FOLDER => $constantAppPath");
    Directory(constantAppPath).createSync(recursive: true);
  }
  print("Create File CANONCIAL $canoncialFile");
  File(canoncialFile).writeAsStringSync(canocialContent);

  // ADD ENV
  String envContent = File("$constantPath/env.dart").readAsStringSync();
  String envFile = "$constantAppPath/env.dart";
  if (!Directory(constantAppPath).existsSync()) {
    print("CREATE FOLDER => $constantAppPath");
    Directory(constantAppPath).createSync(recursive: true);
  }
  print("Create File ENV $envFile");
  File(envFile).writeAsStringSync(envContent);

  // ADD ERROR MESSAGE
  String errorContent = File("$constantPath/error_message.dart").readAsStringSync();
  String errorFile = "$constantAppPath/error_message.dart";
  if (!Directory(constantAppPath).existsSync()) {
    print("CREATE FOLDER => $constantAppPath");
    Directory(constantAppPath).createSync(recursive: true);
  }
  print("Create File ERR $errorFile");
  File(errorFile).writeAsStringSync(errorContent);

  // ADD K
  String kContent = File("$constantPath/K.dart").readAsStringSync();
  String kFile = "$constantAppPath/K.dart";
  if (!Directory(constantAppPath).existsSync()) {
    print("CREATE FOLDER => $constantAppPath");
    Directory(constantAppPath).createSync(recursive: true);
  }
  print("Create File K $kFile");
  File(kFile).writeAsStringSync(kContent);

  // ADD BASE CONTROLLER
  String baseControllerContent = File("$corePath/base/base.controller.dart.stub").readAsStringSync();
  String baseControllerFile = "$coreAppPath/base/base.controller.dart";
  if (!Directory("$coreAppPath/base").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/base");
    Directory("$coreAppPath/base").createSync(recursive: true);
  }
  print("Create File Helper $baseControllerFile");
  File(baseControllerFile).writeAsStringSync(baseControllerContent.replaceAll("appName", appName));

  // ADD BASE VIEW
  String baseViewContent = File("$corePath/base/base.view.dart.stub").readAsStringSync();
  String baseViewFile = "$coreAppPath/base/base.view.dart";
  if (!Directory("$coreAppPath/base").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/base");
    Directory("$coreAppPath/base").createSync(recursive: true);
  }
  print("Create File Helper $baseViewFile");
  File(baseViewFile).writeAsStringSync(baseViewContent.replaceAll("appName", appName));

  // ADD MODEL BASE
  String modelBaseContent = File("$corePath/model/page.state.dart").readAsStringSync();
  String modelBaseFile = "$coreAppPath/model/page.state.dart";
  if (!Directory("$coreAppPath/model").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/model");
    Directory("$coreAppPath/model").createSync(recursive: true);
  }
  print("Create File Helper $modelBaseFile");
  File(modelBaseFile).writeAsStringSync(modelBaseContent);

  // ADD COLOR VALUES
  String appColorContent = File("$corePath/values/app_colors.dart").readAsStringSync();
  String appColorFile = "$coreAppPath/values/app_colors.dart";
  if (!Directory("$coreAppPath/values").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/values");
    Directory("$coreAppPath/values").createSync(recursive: true);
  }
  print("Create File Helper $appColorFile");
  File(appColorFile).writeAsStringSync(appColorContent);

  // ADD VALUES
  String appValuesContent = File("$corePath/values/app_values.dart").readAsStringSync();
  String appValuesFile = "$coreAppPath/values/app_values.dart";
  if (!Directory("$coreAppPath/values").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/values");
    Directory("$coreAppPath/values").createSync(recursive: true);
  }
  print("Create File Helper $appValuesFile");
  File(appValuesFile).writeAsStringSync(appValuesContent);

  // ADD TEXT STYLES VALUES
  String textStylesContent = File("$corePath/values/text_styles.dart.stub").readAsStringSync();
  String textStylesFile = "$coreAppPath/values/text_styles.dart";
  if (!Directory("$coreAppPath/values").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/values");
    Directory("$coreAppPath/values").createSync(recursive: true);
  }
  print("Create File Helper $textStylesFile");
  File(textStylesFile).writeAsStringSync(textStylesContent.replaceAll("appName", appName));

  // ADD HELPER
  String helperContent = File("$corePath/utils/helper.dart.stub").readAsStringSync();
  String helperFile = "$coreAppPath/utils/helper.dart";
  if (!Directory("$coreAppPath/utils").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/utils");
    Directory("$coreAppPath/utils").createSync(recursive: true);
  }
  print("Create File Helper $helperFile");
  File(helperFile).writeAsStringSync(helperContent.replaceAll("appName", appName));

  // ADD APPBAR WIDGET
  String appBarContent = File("$corePath/widget/app_bar_title.dart.stub").readAsStringSync();
  String appBarFile = "$coreAppPath/widget/app_bar_title.dart";
  if (!Directory("$coreAppPath/widget").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/widget");
    Directory("$coreAppPath/widget").createSync(recursive: true);
  }
  // print("Create File Loading Widget $loadingFile");
  File(appBarFile).writeAsStringSync(appBarContent.replaceAll("appName", appName));

  // ADD CUSTOM APPBAR WIDGET
  String customAppBarContent = File("$corePath/widget/custom_app_bar.dart.stub").readAsStringSync();
  String customAppBarFile = "$coreAppPath/widget/custom_app_bar.dart";
  if (!Directory("$coreAppPath/widget").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/widget");
    Directory("$coreAppPath/widget").createSync(recursive: true);
  }
  // print("Create File Loading Widget $loadingFile");
  File(customAppBarFile).writeAsStringSync(customAppBarContent.replaceAll("appName", appName));

  // ADD LOADING WIDGET
  String loadingContent = File("$corePath/widget/loading_widget.dart.stub").readAsStringSync();
  String loadingFile = "$coreAppPath/widget/loading_widget.dart";
  if (!Directory("$coreAppPath/widget").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/widget");
    Directory("$coreAppPath/widget").createSync(recursive: true);
  }
  // print("Create File Loading Widget $loadingFile");
  File(loadingFile).writeAsStringSync(loadingContent.replaceAll("appName", appName));

  // ADD SHIMMER WIDGET
  String shimmerContent = File("$corePath/widget/shimmer_list_widget.dart.stub").readAsStringSync();
  String shimmerFile = "$coreAppPath/widget/shimmer_list_widget.dart";
  if (!Directory("$coreAppPath/widget").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/widget");
    Directory("$coreAppPath/widget").createSync(recursive: true);
  }
  // print("Create File Loading Widget $loadingFile");
  File(shimmerFile).writeAsStringSync(shimmerContent);

  // ADD SNACKBAR WIDGET
  String snackbarContent = File("$corePath/widget/show_snackbar.dart.stub").readAsStringSync();
  String snackbarFile = "$coreAppPath/widget/show_snackbar.dart";
  if (!Directory("$coreAppPath/widget").existsSync()) {
    print("CREATE FOLDER => $coreAppPath/widget");
    Directory("$coreAppPath/widget").createSync(recursive: true);
  }
  // print("Create File Loading Widget $loadingFile");
  File(snackbarFile).writeAsStringSync(snackbarContent);

  // ADD MAIN DEVELOPMENT
  String mainContent = File("$othersPath/main.dart.stub").readAsStringSync();
  String mainDevelopmentFile = "$libAppPath/main_development.dart";
  String mainStagingFile = "$libAppPath/main_staging.dart";
  String mainProductionFile = "$libAppPath/main_production.dart";
  print("Create File Main Development $mainDevelopmentFile");
  File(mainDevelopmentFile).writeAsStringSync(mainContent.replaceAll("appName", appName));
  print("Create File Main Staging $mainDevelopmentFile");
  File(mainStagingFile).writeAsStringSync(mainContent.replaceAll("appName", appName).replaceAll("development", "staging"));
  print("Create File Main Production $mainDevelopmentFile");
  File(mainProductionFile).writeAsStringSync(mainContent.replaceAll("appName", appName).replaceAll("development", "production"));

  // ADD APP
  String appContent = File("$othersPath/app.dart.stub").readAsStringSync();
  String appFile = "$libAppPath/app/app.dart";
  if (!Directory("$libAppPath/app").existsSync()) {
    print("CREATE FOLDER => $libAppPath/app");
    Directory("$libAppPath/app").createSync(recursive: true);
  }
  print("Create File APP $appFile");
  File(appFile).writeAsStringSync(appContent.replaceAll("appName", appName));

  // ADD ROUTER
  if (!Directory(routerAppPath).existsSync()) {
    print("CREATE FOLDER => $routerAppPath");
    Directory(routerAppPath).createSync(recursive: true);
  }

  String routeContent = File("$othersPath/route/route.constant.dart.stub").readAsStringSync();
  String routeFile = "$routerAppPath/route.constant.dart";
  File(routeFile).writeAsStringSync(routeContent);

  String routerGeneratorContent = File("$othersPath/route/route.pages.dart.stub").readAsStringSync();
  String routerGeneratorFile = "$routerAppPath/route.pages.dart";
  File(routerGeneratorFile).writeAsStringSync(routerGeneratorContent.replaceAll("appName", appName));

  // ADD FEATURE SPLASH
  print("add splash feature ....");
  await generate.main(["splash"]);

  // ADD FEATURE HOME
  print("add home feature ....");
  await generate.main(["home"]);

  print("completed ....");
}

class Package {
  String name;
  String version;

  Package(this.name, this.version);
}

List<Package> packages = [
  Package("get", "^4.6.5"),
  Package("get_storage", "^2.0.3"),
  Package("dio", "^4.0.6"),
  Package("shimmer", "^2.0.0"),
  Package("pretty_dio_logger", "^1.1.1"),
  Package("alice", "^0.3.2"),
  Package("intl", "^0.18.0"),
];
