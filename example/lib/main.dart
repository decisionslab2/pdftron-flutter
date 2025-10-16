import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:pdftron_flutter_example/sample_utils.dart';

var enableWidget = true;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Viewer());
  }
}

class Viewer extends StatefulWidget {
  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  String _document =
      "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      PdftronFlutter.initialize("your_pdftron_license_key");
    } on PlatformException {}

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SampleUtils().getSampleFile(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _buildDocumentView(snapshot.data as String);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Scaffold _buildDocumentView(String pdfFilePath) {
    _document = pdfFilePath;
    return Scaffold(
      appBar: AppBar(title: Text("PDFTron Flutter Example")),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: DocumentView(onCreated: _onDocumentViewCreated),
      ),
    );
  }

  void _onDocumentViewCreated(DocumentViewController controller) async {
    try {
      BuildContext documentContext = context;

      // Show loader overlay
      if (documentContext.mounted) {}

      startExportAnnotationCommandListener((xfdfCommand) async {
        await controller.saveDocument();
      });

      startDocumentErrorListener(() {
        print("Document error: ");
      });

      startLeadingNavButtonPressedListener(() async {});

      // Import Annotations
      importAnnotationInDocument() async {
        try {
          var data = await SampleUtils.xfdfData();
          if (data.isNotEmpty) {
            await controller.importAnnotations(data);
          }
        } catch (error) {
          print("Error importing annotations: $error");
        }
      }

      startDocumentLoadedListener((filePath) async {
        print("Document loaded: $filePath");
        // await importAnnotationInDocument();
      });

      await controller.openDocument(
        //passing empty path to test startDocumentErrorListener trigger
        _document,
        config: null,
      );
    } catch (e) {
      print("Error in _onDocumentViewCreated: $e");
    }
  }
}
