import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:crop_image/crop_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Choose File Crop Save'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File? imagevalue;
  double? height;
  double? width;
  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  //Todo process setting\
                  setState(() {
                    height = 300;
                    width = 500;
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)), // Set rounded corner radius
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 20, left: 20),
                  child: const Text(
                    "Setting",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  child: imagevalue == null
                      ? Container()
                      : Image.file(
                          imagevalue!,
                          width: width ?? 600,
                          height: height ?? 400,
                        ),
                ),
              ),
              InkWell(
                onTap: () {
                  height = null;
                  width = null;
                  chooseFile();
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                          Radius.circular(4.0)), // Set rounded corner radius
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 20, left: 20),
                    child: const Text(
                      "Choose",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  String? outputFile = await FilePicker.platform.saveFile(
                    dialogTitle: 'Please select an output file:',
                    fileName: 'output-file',
                  );

                  // File file = File(imagevalue?.path ?? ''); // 1
                  // file.writeAsString(
                  //     "This is my demo text that will be saved to : demoTextFile.txt"); // 2
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                          Radius.circular(4.0)), // Set rounded corner radius
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 20, left: 20),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void chooseFile() async {
    FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        allowedExtensions: ['png', 'jpg', 'svg', 'jpeg']);

    if (filePickerResult != null) {
      PlatformFile file = filePickerResult.files.first;
      File file1 = File(filePickerResult.files.single.path ?? '');
      print("PHUCBV: ==> $filePickerResult");
      //  PlatformFile file = result.files.first;
      print("PHUCBV: 1 ==> $file");
      setState(() {
        imagevalue = file1;
      });
      // for(PlatformFile file in filePickerResult.files){

      // }
    }
  }
}
