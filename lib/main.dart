import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker_desktop/file_picker_desktop.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:crop_image/crop_image.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

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
  File? imagevalue;
  double? height;
  double? width;
  final controller = CropController(
    aspectRatio: 1.5,
    defaultCrop: const Rect.fromLTRB(0.2, 0.2, 0.5, 0.5),
  );
  Rect? rect;
  List<File> filesItemCrop = [];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
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
                  // setState(() {
                  //   height = 300;
                  //   width = 500;
                  // });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
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
                    child: filesItemCrop.isEmpty
                        ? Container() :
                    //     : Container(
                    //   child: Image.file(
                    //     imagevalue!,
                    //     width: 600,
                    //     height: 400,
                    //     fit: BoxFit.fill,
                    //   ),
                    // ))
                    Container(
                      width: 800,
                      // height: 600,
                      color: Colors.yellow,
                      alignment: Alignment.center,
                      // decoration: BoxDecoration(
                      //   image: DecorationImage(
                      //     fit: BoxFit.fill,
                      //     image: NetworkImage("https://picsum.photos/250?image=9"),
                      //   ),
                      // ),
                      child:ListView.builder(
                        itemCount: filesItemCrop.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, i) {
                          return itemCrop(filesItemCrop[i]);
                        },
                      )
                    )),
              ),
              InkWell(
                onTap: () async {
                  // height = null;
                  // width = null;
                  chooseFile();
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
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
                  // _save();
                  filesItemCrop.forEach((element) async {
                    final xpath = element!.path;
                    final bytes = await File(xpath).readAsBytes();
                    final img.Image? newImage = img.decodeImage(bytes);


                    int w = newImage!.width;
                    int h = newImage.height;
                    double wTP = (rect!.right - (rect!.left ?? 0));
                    double hTP = (rect!.bottom - (rect!.top ?? 0));
                    img.Image crop = img.copyCrop(
                        newImage,
                        (rect!.left * w).toInt(),
                        (rect!.top * h).toInt(),
                        (wTP*w).toInt(),
                        (hTP*h).toInt());

                    // img.Image crop = img.copyCrop(
                    //     newImage!,
                    //     (newImage.width/2).toInt() - ((newImage.width*2/3).toInt()/2).toInt(),
                    //     (newImage.height/2).toInt() - ((newImage.height*2/3).toInt()/2).toInt(),
                    //     (newImage.width*2/3).toInt(),
                    //     (newImage.height*2/3).toInt());
                    final jpg = img.encodeJpg(crop);
                    File cropSaveFile = File(xpath);
                    final String? selectedFileName = await saveFile(
                      defaultFileName: DateTime.now().millisecondsSinceEpoch.toString(),
                    );
                    await File(selectedFileName ?? '').writeAsBytes(jpg);
                  });
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
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

  Widget itemCrop(File file) {
    return CropImage(
      image: Image.file(
        file!,
        width: 800,
        height: 600,
        fit: BoxFit.fill,
      ),
      controller: controller,
      // alwaysShowThirdLines: true,
      onCrop: (Rect r) async {
        setState(() {
          // rect = r;
          // controller.aspectRatio = 1.5;
          // controller.crop = r;
          // Rect finalCropRelative = controller.crop;

          Rect finalCropPixels = controller.cropSize;
          rect = r;
          print("ImageCheck1 : $finalCropPixels  ::: ${rect?.bottomRight.direction}");
          print("ImageCheck12 : left : ${r.left} : right: ${r.right}: top:${r.top} : bottom :${r.bottom}");
        });
      },
    );
  }
  void chooseFile() async {
    // FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
    //     allowMultiple: true,
    //     type: FileType.image,
    //     allowedExtensions: ['png', 'jpg', 'svg', 'jpeg']);
    //
    // if (filePickerResult != null) {
    //   PlatformFile file = filePickerResult.files.first;
    //   File file1 = File(filePickerResult.files.single.path ?? '');
    //   print("PHUCBV: ==> $filePickerResult");
    //   //  PlatformFile file = result.files.first;
    //   print("PHUCBV: 1 ==> $file");
    //   setState(() {
    //     imagevalue = file1;
    //   });

    // }

    try {
      var result = await pickFiles(
        allowMultiple: true,
      );
      
      if (result != null) {
        // File? file = File(result.files.single.path ?? '');

        setState(() {
          // imagevalue = file;
          filesItemCrop = result.paths.map((path) => File(path!)).toList();
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print(e);
    }
  }


  _save() async {
    // await ImageGallerySaver.saveImage(
    //    imagevalue!.readAsBytesSync());

    // String? outputFile = await FilePicker.platform.saveFile(
    //   dialogTitle: 'Please select an output file:',
    //   fileName: 'output-file',
    // );
    // var image = await controller.croppedImage();
    // Uint8List bodyBytes = imagevalue!.readAsBytesSync();
    // File('my_image.jpg').writeAsBytes(bodyBytes);
    //Todo

    Image image = await controller.croppedImage();

    //   try {
    //     final String? selectedFileName = await saveFile(
    //       defaultFileName: 'default-file.png',
    //     );
    //
    //     if (selectedFileName != null) {
    //       await File(selectedFileName).writeAsBytes(imagevalue!.readAsBytesSync());
    //     } else {
    //       // User canceled the picker
    //     }
    //   } catch (e) {
    //     print(e);
    //   }
  }
}
