import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:collection/collection.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as p;

class SampleUtils {
  static Config annotateConfig(String userID, String userDisplayName) {
    Config config = Config();

    List<Object>? tools = [
      Buttons.stickyToolButton,
      Buttons.freeHandToolButton,
      Buttons.freeTextToolButton,
      Buttons.highlightToolButton,
      Buttons.redo,
      Buttons.undo,
    ];

    CustomToolbar customToolBar = CustomToolbar(
      '01',
      "Annotate",
      tools,
      ToolbarIcons.annotate,
    );

    config.annotationToolbars = [DefaultToolbars.view, customToolBar];
    config.longPressMenuItems = ["delete"];
    config.thumbnailViewEditingEnabled = true;
    config.autoResizeFreeTextEnabled = true;
    config.outlineListEditingEnabled = false;
    config.selectAnnotationAfterCreation = false;
    config.fitMode = FitModes.fitPage;
    config.downloadDialogEnabled = false;
    config.topAppNavBarRightBar = [Buttons.searchButton];
    config.showDocumentSavedToast = false;

    config.hideDefaultAnnotationToolbars = [
      DefaultToolbars.favorite,
      DefaultToolbars.prepareForm,
      DefaultToolbars.measure,
      DefaultToolbars.fillAndSign,
      DefaultToolbars.pens,
      DefaultToolbars.draw,
      DefaultToolbars.redaction,
      DefaultToolbars.insert,
    ];

    var disabledElements = [
      Buttons.viewLayersButton,
      Buttons.viewControlsButton,
      Buttons.calloutToolButton,
      Buttons.moreItemsButton,
      Buttons.underlineToolButton,
      Buttons.squigglyToolButton,
      Buttons.editMenuButton,
      Buttons.shareButton,
      Buttons.viewControlsButton,
      Buttons.editPagesButton,
      Buttons.editAnnotationToolbarButton,
      Buttons.cropPageButton,
      Buttons.editPagesButton,
      Buttons.thumbnailsButton,
    ];
    config.disabledTools = [
      Tools.pencilKitDrawing, //NE
      Tools.formCreateComboBoxField,
      Tools.annotationEdit,
      Tools.annotationSmartPen, //NE
      Tools.annotationCreateTextStrikeout,
      //Tools.annotationCreateFreeHand //NE
    ];

    config.annotationMenuItems = [
      AnnotationMenuItems.share,
      AnnotationMenuItems.delete,
    ];
    config.longPressMenuEnabled = true;
    config.annotationToolbarAlignment = ToolbarAlignment.End;
    config.autoSaveEnabled = true;
    config.disabledElements = disabledElements;
    config.multiTabEnabled = false;
    config.openSavedCopyInNewTab = false;
    config.bottomToolbar = [Buttons.listsButton, Buttons.thumbnailsButton];
    config.userId = userID;
    config.userName = userDisplayName;
    config.annotationAuthor = userDisplayName;
    config.rememberLastUsedTool = true;
    config.pageChangeOnTap = false;
    config.hideToolbarsOnTap = false;
    config.imageInReflowModeEnabled = false;
    config.continuousAnnotationEditing = true;
    return config;
  }

  Future<String?> getSampleFile() async {
    try {
      String newFileName = "newSample.pdf";
      String? localPath = await getCachedFilePathByName(fileName: newFileName);

      if (localPath != null) {
        print('Cached file found: $newFileName');
        return localPath;
      }
      print('Cached file not found:newSample.pdf');
      var download = await downloadFileToDevice(
        url:
            "https://drive.google.com/uc?export=download&id=1Tq7etabrdQTd9wYMeUuVXzfzFBXy2e5d",
        //'https://drive.google.com/uc?export=download&id=1R6K33q8CrUuzF1CDdXPD25-Gxr9v9LgO',
        foldername: "SampleBooks",
        filename: newFileName,
      );
      return download.path;
    } catch (e) {
      print('Error finding cached file: $e');
      return null;
    }
  }

  static Future<String> getDirectoryPath({required String folderName}) async {
    String dir = (await getApplicationSupportDirectory()).path;
    return p.join(dir, _getDirectoryName(directoryName: folderName));
  }

  static String _getDirectoryName({required String directoryName}) {
    return p.join("Meetings", directoryName);
  }

  static Future<io.File> generateFile({
    required String folderName,
    required String? fileName,
  }) async {
    return await _initDirectoryLookUp(folderName: folderName).then((
      value,
    ) async {
      return io.File(
        await getFilePath(folderName: folderName, fileName: fileName),
      );
    });
  }

  static Future<io.Directory> _initDirectoryLookUp({
    required String folderName,
  }) async {
    print("Checking directory: $folderName");
    if (!await _checkDirectoryExist(folderName: folderName)) {
      print("Directory does not exist");
      print("Creating directory....");
      await io.Directory(
        await getDirectoryPath(folderName: folderName),
      ).create(recursive: true).whenComplete(() => print("Directory created"));
    }
    return io.Directory(await getDirectoryPath(folderName: folderName));
  }

  static Future<bool> _checkDirectoryExist({required String folderName}) async {
    bool isExist = await io.Directory(
      await getDirectoryPath(folderName: folderName),
    ).exists();
    print("$folderName Directory Exist: $isExist");
    return isExist;
  }

  static Future<String> getFilePath({
    required String folderName,
    required String? fileName,
  }) async {
    String dir = (await getApplicationSupportDirectory()).path;
    return p.join(dir, _getDirectoryName(directoryName: folderName), fileName);
  }

  Future<io.File> downloadFileToDevice({
    required String url,
    required String foldername,
    required String? filename,
  }) async {
    try {
      io.File file = (await generateFile(
        folderName: foldername,
        fileName: filename,
      ));
      Dio newDio = Dio();
      var response = await newDio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      var bytes = response.data as Uint8List;
      print(file.path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print("Error downloading file: $e");
      throw Exception("Failed to download file: $e");
    }
  }

  static Future<String> xfdfData() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://drive.google.com/uc?export=download&id=12lKp--x8EcUKOErQkdXB3mL8GoVS_F13',
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: true,
        ),
      );
      print("XFDF Data loaded successfully");
      return response.data.toString();
    } catch (e) {
      print("Error fetching XFDF data: $e");
      return "";
    }
  }

  static Future<String?> getCachedFilePathByName({
    required String? fileName,
  }) async {
    if (fileName == null || fileName.isEmpty) {
      return null;
    }
    final allPaths = await listAllCachedFiles();

    try {
      var path = allPaths.firstWhereOrNull(
        (path) => p.basename(path) == fileName,
      );
      if (path == null) {
        return null;
      }
      return path;
    } catch (e) {
      print("Error finding cached file by name: $e");
      return null;
    }
  }

  static Future<List<String>> listAllCachedFiles() async {
    try {
      final folderPath = await getDirectoryPath(folderName: "SampleBooks");
      final folder = io.Directory(folderPath);

      if (!await folder.exists()) {
        await folder.create(recursive: true);
        return <String>[];
      }

      final entities = await folder.list().toList();
      return entities.whereType<io.File>().map((file) => file.path).toList();
    } catch (e) {
      print("Error listing cached files: $e");
      return [];
    }
  }
}
